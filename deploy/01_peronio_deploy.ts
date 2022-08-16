import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';

import { getConstructorParams } from "../utils/helpers";

const peronioDeploy: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
    console.info("Deploying Peronio");
    const { getNamedAccounts, deployments } = hre;

    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    await deploy("Peronio", {
        contract: "Peronio",
        from: deployer,
        log: true,
        args: Object.values(getConstructorParams()),
    });
};

export default peronioDeploy;
