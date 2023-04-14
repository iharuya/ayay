import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const entryPointAddress = (await hre.deployments.get("EntryPoint")).address
  const {deployer} = await hre.getNamedAccounts()
  await hre.deployments.deploy('AyAyFactory', {
    from: deployer,
    log: true,
    args: [entryPointAddress],
  });
};
export default func;