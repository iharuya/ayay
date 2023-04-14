// Ref: @account-abstraction/sdk/dist/src/SimpleAccountAPI

import { JsonRpcProvider } from "@ethersproject/providers"
import {
  AyAyFactory,
  AyAyFactory__factory,
  AyAyPaymaster,
  AyAyPaymaster__factory,
  AyAyReceiver,
  AyAyReceiver__factory,
  AyAyWallet,
  AyAyWallet__factory,
} from "../typechain-types"
import { BigNumber, BigNumberish, ethers } from "ethers"
import { HttpRpcClient } from "@account-abstraction/sdk"
import { EntryPoint } from "@account-abstraction/contracts/types"
import { EntryPoint__factory } from "@account-abstraction/contracts"
import { UserOperation } from "../types/UserOperation"
import { fillUserOp } from "./user-operation"

type ConsumerParams = {
  masterAddress: string
  index?: number
}
type PaymentParams = {
  token: string
  amount: BigNumber
}

type BusinessApiParams = {
  provider: JsonRpcProvider
  entryPointAddress: string
  factoryAddress: string
  receiverAddress: string
  paymasterAddress: string
  bundlerUrl: string
  chainId: number
}
/**
 * 事業者が利用するApi
 * Swift上で動かしたい
 * 最悪Web apiサーバー上に置く
 */
export class BusinessApi {
  private provider: JsonRpcProvider
  private entryPoint: EntryPoint
  private factory: AyAyFactory
  private receiver: AyAyReceiver
  private paymaster: AyAyPaymaster
  private rpcClient: HttpRpcClient
  constructor(params: BusinessApiParams) {
    this.provider = params.provider
    this.entryPoint = EntryPoint__factory.connect(
      params.entryPointAddress,
      params.provider
    )
    this.factory = AyAyFactory__factory.connect(
      params.factoryAddress,
      params.provider
    )
    this.receiver = AyAyReceiver__factory.connect(
      params.receiverAddress,
      params.provider
    )
    this.paymaster = AyAyPaymaster__factory.connect(
      params.paymasterAddress,
      params.provider
    )
    this.rpcClient = new HttpRpcClient(
      params.bundlerUrl,
      params.entryPointAddress,
      params.chainId
    )
  }

  private async getWalletInitCode(params: ConsumerParams) {
    return ethers.utils.hexConcat([
      this.factory.address,
      this.factory.interface.encodeFunctionData("createAccount", [
        params.masterAddress,
        params.index ?? 0
      ])
    ])
  }

  async getWalletAddress(params: ConsumerParams): Promise<string> {
    const initCode = await this.getWalletInitCode(params)
    let address: string | null = null
    try {
      await this.entryPoint.callStatic.getSenderAddress(initCode)
    } catch (result: any) {
      address = result?.errorArgs?.sender || null
    }
    if (address === null) {
      throw new Error("Failed to get counter factual address")
    }
    return address
  }

  private async isWalletPhantom(consumer: ConsumerParams): Promise<boolean> {
    const walletAddress = await this.getWalletAddress(consumer)
    const walletCode = await this.provider.getCode(walletAddress)
    return walletCode.length > 2 ? false : true
  }

  private async getWallet(consumer: ConsumerParams): Promise<AyAyWallet> {
    const walletAddress = await this.getWalletAddress(consumer)
    return AyAyWallet__factory.connect(walletAddress, this.provider)
  }

  private async getNonce(consumer: ConsumerParams): Promise<BigNumber> {
    if (await this.isWalletPhantom(consumer)) {
      return ethers.BigNumber.from(0)
    }
    const wallet = await this.getWallet(consumer)
    return await wallet.nonce()
  }

  async getUserOpReceipt(opHash: string) {
    const timeout = 30000
    const interval = 5000
    const endtime = Date.now() + timeout
    while (Date.now() < endtime) {
      const events = await this.entryPoint.queryFilter(
        this.entryPoint.filters.UserOperationEvent(opHash)
      )
      if (events.length > 0) {
        return events[0].transactionHash
      }
      await new Promise((resolve) => setTimeout(resolve, interval))
    }
    return null
  }

  async encodePay(consumer: ConsumerParams, payment: PaymentParams) {
    const wallet = await this.getWallet(consumer)
    return wallet.interface.encodeFunctionData("pay", [
      this.receiver.address,
      payment.token,
      payment.amount
    ])
  }

  async createUnsignedPaymentOp(
    consumer: ConsumerParams,
    payment: PaymentParams
  ) {
    const partialOp: Partial<UserOperation> = {
      sender: await this.getWalletAddress(consumer),
      nonce: await this.getNonce(consumer),
      initCode: (await this.isWalletPhantom(consumer))
        ? await this.getWalletInitCode(consumer)
        : undefined,
      callData: await this.encodePay(consumer, payment),
      paymasterAndData: ethers.utils.hexConcat([this.paymaster.address])
    }
    const filledUserOp = await fillUserOp(partialOp, this.entryPoint)
    return filledUserOp
  }

  async sendOpToMempool(op: UserOperation) {
    const paymentHash = await this.rpcClient.sendUserOpToBundler(op)
    return paymentHash
  }
}
