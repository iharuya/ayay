import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const {deploy, getArtifact} = hre.deployments
  const {deployer} = await hre.getNamedAccounts()
  const artifact = await getArtifact("EntryPoint");
  await deploy('EntryPoint', {
    from: deployer,
    contract: artifact,
    log: true,
    args: [],
    deterministicDeployment: true
  });
};
export default func;