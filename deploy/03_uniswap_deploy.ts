import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Address, DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat";

import { UniswapV2Factory } from "../typechain-types";

const uniswapDeploy: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
    console.info("Deploying Uniswap");

    const { deployer } = await hre.getNamedAccounts();

    console.info("Deploying Factory");
    const factoryAddress: Address = (
        await hre.deployments.deploy("UniswapV2Factory", {
            contract: "UniswapV2Factory",
            from: deployer,
            log: true,
            args: [deployer],
        })
    ).address;

    const factoryContract: UniswapV2Factory = await ethers.getContractAt("UniswapV2Factory", factoryAddress);

    console.info(`Setting fee receiver to ${process.env.TREASURY_ADDRESS}`);
    await factoryContract.setFeeTo(process.env.TREASURY_ADDRESS ?? "");

    console.info("Deploying Router");
    await hre.deployments.deploy("UniswapV2Router02", {
        contract: "UniswapV2Router02",
        from: deployer,
        log: true,
        args: [factoryContract.address, process.env.WMATIC_ADDRESS],
    });
};

export default uniswapDeploy;
