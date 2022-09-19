import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Address, DeployFunction } from "hardhat-deploy/types";
import { keccak256 } from "ethers/lib/utils";

import { Peronio } from "../typechain-types";
import { ethers } from "hardhat";

const MIGRATOR_ROLE: string = keccak256(new TextEncoder().encode("MIGRATOR_ROLE"));

const deployMigrator: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
    console.info("Deploying Migrator");
    const { deployer } = await hre.getNamedAccounts();

    const peronioV1Address = process.env.PERONIO_V1_ADDRESS;
    const peronioV2Address = (await hre.deployments.get("Peronio")).address;

    const peronioV2Contract: Peronio = await ethers.getContractAt("Peronio", peronioV2Address);

    const migratorAddress: Address = (
        await hre.deployments.deploy("Migrator", {
            contract: "Migrator",
            from: deployer,
            log: true,
            args: [peronioV1Address, peronioV2Address],
        })
    ).address;

    await peronioV2Contract.grantRole(MIGRATOR_ROLE, migratorAddress);
};

export default deployMigrator;
