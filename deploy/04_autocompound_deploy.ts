// deploy/04_deploy_peronio.ts
import { keccak256 } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";

import { Peronio } from "../typechain";

module.exports = async () => {
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

module.exports.tags = ["AutoCompound"];
