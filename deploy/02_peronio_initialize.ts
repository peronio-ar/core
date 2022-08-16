import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { ethers } from "hardhat";

import { getInitializeParams } from "../utils/helpers";
import { Peronio, ERC20 } from "../typechain-types";
import { IPeronioInitializeParams } from "../utils/types/IPeronioInitializeParams";

const peronioInitialize: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
    console.info("Initializing Peronio");
    const { get } = hre.deployments;

    const peronioInitialize: IPeronioInitializeParams = getInitializeParams();

    const usdcContract: ERC20 = await ethers.getContractAt("ERC20", process.env.USDC_ADDRESS ?? "");
    const peronioContract: Peronio = await ethers.getContractAt("Peronio", (await get("Peronio")).address);

    // Approve
    await usdcContract.approve(peronioContract.address, peronioInitialize.usdcAmount);

    // Initialize
    await peronioContract.initialize(peronioInitialize.usdcAmount, peronioInitialize.startingRatio);
};

export default peronioInitialize;
