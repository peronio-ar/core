import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { ethers } from "hardhat";

import { getInitializeParams } from "../utils/helpers";
import { Peronio, ERC20 } from "../typechain-types";
import { IPeronioInitializeParams } from "../utils/types/IPeronioInitializeParams";

const peronioInitialize: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
    console.info("Initializing Peronio");

    const peronioInitializeParams: IPeronioInitializeParams = getInitializeParams();

    const usdcContract: ERC20 = await ethers.getContractAt("ERC20", process.env.USDC_ADDRESS ?? "");
    const peronioContract: Peronio = await ethers.getContractAt("Peronio", (await hre.deployments.get("Peronio")).address);

    // Approve
    await usdcContract.approve(peronioContract.address, peronioInitializeParams.usdcAmount);

    // Initialize
    await peronioContract.initialize(peronioInitializeParams.usdcAmount, peronioInitializeParams.startingRatio);
};

export default peronioInitialize;
