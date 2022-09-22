import { BigNumber, ContractTransaction } from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
// eslint-disable-next-line node/no-unpublished-import
import { setBalance } from "@nomicfoundation/hardhat-network-helpers";
import { UniswapV2Router02 } from "../typechain-types";
import { ethers } from "hardhat";

const swapMATICtoUSDC = async (
    uniswapContractAddress: string,
    wmaticAddress: string,
    usdcAddress: string,
    to: string,
    amount: string,
): Promise<ContractTransaction> => {
    const quickswapRouter: UniswapV2Router02 = await ethers.getContractAt("UniswapV2Router02", uniswapContractAddress);

    return await quickswapRouter.swapExactETHForTokens(BigNumber.from("1"), [wmaticAddress, usdcAddress], to, "9999999999999999999", {
        value: BigNumber.from(amount),
    });
};

const localHardhat = async (hre: HardhatRuntimeEnvironment) => {
    if (hre.network.name !== "hardhat") {
        return;
    }
    console.info("-- Hardhat network");
    const accounts = await hre.getNamedAccounts();

    // Mint MATIC to deployer account
    console.info("Increase MATIC");
    await setBalance(accounts.deployer, BigNumber.from("1000000000000000000000000000"));

    // Swap MATIC into USDC from QuickSwap Router
    console.info("Swapping MATIC into USDC");
    await swapMATICtoUSDC(
        process.env.QUICKSWAP_ROUTER_ADDRESS ?? "",
        process.env.WMATIC_ADDRESS ?? "",
        process.env.USDC_ADDRESS ?? "",
        accounts.deployer,
        "10000000000000000000000000",
    );
};

export default localHardhat;
