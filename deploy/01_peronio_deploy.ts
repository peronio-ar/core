import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Address, DeployFunction } from "hardhat-deploy/types";

import { getConstructorParams } from "../utils/helpers";

const peronioDeploy: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
    console.info("Deploying Peronio");
    const { deployer } = await hre.getNamedAccounts();

    await hre.deployments.deploy("Peronio", {
        contract: "Peronio",
        from: deployer,
        log: true,
        args: Object.values(getConstructorParams()),
    });
};

export default peronioDeploy;
