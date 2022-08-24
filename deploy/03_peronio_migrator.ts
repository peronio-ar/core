import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployMigrator: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
    console.info("Deploying Peronio V1 Wrapper");
    const { deployer } = await hre.getNamedAccounts();

    const peronioV1Address = process.env.PERONIO_V1_ADDRESS;
    const peronioV2Address = (await hre.deployments.get("Peronio")).address;

    await hre.deployments.deploy("Migrator", {
        contract: "Migrator",
        from: deployer,
        log: true,
        args: [peronioV1Address, peronioV2Address],
    });
};

export default deployMigrator;