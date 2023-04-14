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
import { getSignerFromAddress } from "../lib/hardhat-utils"

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

  const consumer1_defaultIndex = 0
  const consumer1_wallet1Address = await factory.getAddress(
    consumer1,
    consumer1_defaultIndex
  )
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

  const deployerSigner = await getSignerFromAddress(deployer)
  const shop1Signer = await getSignerFromAddress(shop1)

  const consumer1_wallet1Balance = await testJpyc.balanceOf(
    consumer1_wallet1Address
  )
  if (consumer1_wallet1Balance.lt(ethers.utils.parseUnits("1000", 6))) {
    console.log(`Sending consumer1 wallet 1 1000 JPYC...`)
    await (
      await testJpyc
        .connect(deployerSigner)
        .transfer(consumer1_wallet1Address, ethers.utils.parseUnits("1000", 6))
    ).wait(networkConfigHelper?.confirmations || 1)
  }

  const shop1PaymasterDeposit = await shop1_paymaster.getDeposit()
  if (shop1PaymasterDeposit.lt(ethers.utils.parseEther("0.1"))) {
    console.log("paymaster depositting and staking...")
    await shop1_paymaster
      .connect(shop1Signer)
      .deposit({ value: ethers.utils.parseEther("0.1") })
    await (
      await shop1_paymaster
        .connect(shop1Signer)
        .addStake(10000, { value: ethers.utils.parseEther("0.1") })
    ).wait(networkConfigHelper?.confirmations || 1)
  }

  // This api creates unsigned payment op, sends signed op. This does not store consumer info
  const business1Api = new BusinessApi({
    entryPointAddress: entryPoint.address,
    factoryAddress: factory.address,
    paymasterAddress: shop1_paymaster.address,
    receiverAddress: shop1_receiver.address,
    bundlerUrl: networkConfigHelper?.bundlerUrl!,
    chainId: await getChainIdFromProvider(ethers.provider),
    provider: ethers.provider
  })

  const unsignedOp = await business1Api.createUnsignedPaymentOp(
    { masterAddress: consumer1, index: consumer1_defaultIndex },
    { token: testJpyc.address, amount: ethers.utils.parseUnits("100", 6) }
  )
  console.log({ unsignedOp })
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
