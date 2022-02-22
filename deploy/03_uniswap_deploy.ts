// deploy/03_uniswap_deploy.ts
import hre, { ethers } from "hardhat";

import { UniswapV2Factory } from "../typechain";

module.exports = async () => {
  console.info("Deploying Uniswap");
  const { getNamedAccounts, deployments } = hre;

  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.info("Deploying Factory");
  const { address: factoryAddress } = await deploy("UniswapV2Factory", {
    contract: "UniswapV2Factory",
    from: deployer,
    log: true,
    args: [deployer],
  });

  const factoryContract: UniswapV2Factory = await ethers.getContractAt(
    "UniswapV2Factory",
    factoryAddress
  );

  console.info("Setting fee receiver to " + process.env.TREASURY_ADDRESS);
  (await factoryContract.setFeeTo(process.env.TREASURY_ADDRESS ?? "")).wait();

  console.info("Deploying Router");
  await deploy("UniswapV2Router02", {
    contract: "UniswapV2Router02",
    from: deployer,
    log: true,
    args: [factoryContract.address, process.env.WMATIC_ADDRESS],
  });
};

module.exports.tags = ["Uniswap"];
