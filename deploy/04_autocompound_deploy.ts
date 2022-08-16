import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { ethers } from "hardhat";

import { keccak256 } from "ethers/lib/utils";

import { Peronio } from "../typechain-types";

const autocompoundDeploy: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
    console.info("Deploying Uniswap");
    const { getNamedAccounts, deployments } = hre;
    const { deploy, get } = deployments;
    const { deployer } = await getNamedAccounts();

    const peronioContract: Peronio = await ethers.getContractAt("Peronio", (await get("Peronio")).address);

    console.info("Deploying AutoCompound");
    const { address: autocompoundAddress } = await deploy("AutoCompounder", {
        contract: "AutoCompounder",
        from: deployer,
        log: true,
        args: [peronioContract.address],
    });

    console.info(`Setting REWARD Role to AutoCompounder (${autocompoundAddress})`);
    await peronioContract.grantRole(keccak256(new TextEncoder().encode("REWARDS_ROLE")), peronioContract.address);
};

export default autocompoundDeploy;
