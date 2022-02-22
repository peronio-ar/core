// deploy/01_peronio_deploy.ts
import hre from "hardhat";
import { getConstructorParams } from "../helpers/peronio";
import { IPeronioConstructorParams } from "../types/utils";

// module.exports = async ({ getNamedAccounts, deployments }) => {
module.exports = async () => {
  console.info("Deploying Peronio");
  const { getNamedAccounts, deployments } = hre;

  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const peronioContructor: IPeronioConstructorParams = getConstructorParams();

  await deploy("Peronio", {
    contract: "Peronio",
    from: deployer,
    log: true,
    args: [
      peronioContructor.name,
      peronioContructor.symbol,
      peronioContructor.usdcAddress,
      peronioContructor.maiAddress,
      peronioContructor.lpAddress,
      peronioContructor.qiAddress,
      peronioContructor.quickswapRouterAddress,
      peronioContructor.qiFarmAddress,
      peronioContructor.qiPoolId,
    ],
  });
};

module.exports.tags = ["Peronio"];
