import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';

// @note receiver and paymaster should be modules of BUNZZ so that shops can deploy them easily
const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const entryPointAddress = (await hre.deployments.get("EntryPoint")).address
  const {deployer, shop1} = await hre.getNamedAccounts()
  await hre.deployments.deploy("TestJPYC", {
    from: deployer,
    log: true,
    args: [],
  })
  const testJpycAddress = (await hre.deployments.get("TestJPYC")).address
  await hre.deployments.deploy("Shop1_Receiver", {
    contract: "AyAyReceiver",
    from: shop1,
    log: true,
    args: [shop1, testJpycAddress]
  })
  const shop1_receiverAddress = (await hre.deployments.get("Shop1_Receiver"))
    .address
  await hre.deployments.deploy("Shop1_Paymaster", {
    contract: "AyAyPaymaster",
    from: shop1,
    log: true,
    args: [
      entryPointAddress,
      shop1_receiverAddress,
      shop1
    ],
    
  })

};
export default func;