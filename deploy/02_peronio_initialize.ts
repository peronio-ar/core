// deploy/02_peronio_initialize.ts
import hre, { ethers } from "hardhat";

import { getInitializeParams } from "../utils/helpers";
import { Peronio, ERC20 } from "../typechain-types";
import { IPeronioInitializeParams } from "../utils/types/IPeronioInitializeParams";

module.exports = async () => {
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

module.exports.tags = ["Initialize"];
