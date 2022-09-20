import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Address, DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat";

import { keccak256 } from "ethers/lib/utils";

/* eslint-disable node/no-unpublished-import */
import { Peronio } from "../typechain-types";
/* eslint-enable node/no-unpublished-import */

const cumpaDeploy: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
    console.info("Deploying Uniswap");

    const { deployer } = await hre.getNamedAccounts();

    const peronioContract: Peronio = await ethers.getContractAt("Peronio", (await hre.deployments.get("Peronio")).address);

    console.info("Deploying Cumpa");
    const cumpaAddress: Address = (
        await hre.deployments.deploy("Cumpa", {
            contract: "Cumpa",
            from: deployer,
            log: true,
            args: [peronioContract.address],
        })
    ).address;

    console.info(`Setting REWARD Role to Cumpa (${cumpaAddress})`);
    await peronioContract.grantRole(keccak256(new TextEncoder().encode("REWARDS_ROLE")), cumpaAddress);
};

export default cumpaDeploy;
