import { EntryPoint__factory } from "@account-abstraction/contracts"
import { deployments, ethers, getNamedAccounts, network } from "hardhat"
import {
  AyAyFactory__factory,
  AyAyPaymaster__factory,
  AyAyReceiver__factory,
  AyAyWallet__factory,
  TestJPYC__factory
} from "../typechain-types"
import { BusinessApi } from "../lib/BusinessApi"
import { networksConfig } from "../helper"
import { assertIsDefined, getChainIdFromProvider } from "../lib/utils"

const networkConfigHelper = networksConfig[network.name]
assertIsDefined(networkConfigHelper?.bundlerUrl)

async function main() {
  const { deployer, shop1, consumer1 } = await getNamedAccounts()
  // consumer1 is master EOA, not ayay wallet
  const entryPointAddress = (await deployments.get("EntryPoint")).address
  const entryPoint = EntryPoint__factory.connect(
    entryPointAddress,
    ethers.provider
  )
  const factoryAddress = (await deployments.get("AyAyFactory")).address
  const factory = AyAyFactory__factory.connect(factoryAddress, ethers.provider)
  const testJpycAddress = (await deployments.get("TestJPYC")).address
  const testJpyc = TestJPYC__factory.connect(testJpycAddress, ethers.provider)
  const shop1_receiverAddress = (await deployments.get("Shop1_Receiver"))
    .address
  const shop1_receiver = AyAyReceiver__factory.connect(
    shop1_receiverAddress,
    ethers.provider
  )
  const shop1_paymasterAddress = (await deployments.get("Shop1_Paymaster"))
    .address
  const shop1_paymaster = AyAyPaymaster__factory.connect(
    shop1_paymasterAddress,
    ethers.provider
  )

  const consumer1_wallet1Address = await factory.getAddress(consumer1, 0)
  const consumer1_wallet1 = AyAyWallet__factory.connect(
    consumer1_wallet1Address,
    ethers.provider
  )
  console.log({
    entryPoint: entryPoint.address,
    factory: factory.address,
    testJpyc: testJpyc.address,
    shop1_receiver: shop1_receiver.address,
    shop1_paymaster: shop1_paymaster.address,
    consumer1_wallet1Address: consumer1_wallet1.address
  })

  // create BusinessApi that creates unsigned op, sends signed op
  // This api does not store consumer info
  // consumer signs it and businessApi.sendOp(signedOp)
  // in bluetooth, transforming data should be simple
  const business1Api = new BusinessApi({
    entryPointAddress: entryPoint.address,
    factoryAddress: factory.address,
    paymasterAddress: shop1_paymaster.address,
    receiverAddress: shop1_receiver.address,
    bundlerUrl: networkConfigHelper?.bundlerUrl!,
    chainId: await getChainIdFromProvider(ethers.provider),
    provider: ethers.provider
  })

}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
