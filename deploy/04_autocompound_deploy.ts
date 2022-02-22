// deploy/04_deploy_peronio.ts
import hre, { ethers } from "hardhat";

import { Peronio } from "../typechain";

module.exports = async () => {
  console.info("Deploying Uniswap");
  const { getNamedAccounts, deployments } = hre;
  const { deploy, get } = deployments;
  const { deployer } = await getNamedAccounts();

  const peronioContract: Peronio = await ethers.getContractAt(
    "Peronio",
    (
      await get("Peronio")
    ).address
  );

  console.info("Deploying AutoCompound");
  const { address: autocompoundAddress } = await deploy("Autocompounder", {
    contract: "Autocompounder",
    from: deployer,
    log: true,
    args: [peronioContract.address],
  });

  console.info("Setting fee receiver to " + autocompoundAddress);
  const rewardRole =
    "0x5407862f04286ebe607684514c14b7fffc750b6bf52ba44ea49569174845a5bd";
  await peronioContract.grantRole(rewardRole, peronioContract.address);
};

module.exports.tags = ["AutoCompound"];
