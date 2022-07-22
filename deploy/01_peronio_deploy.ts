// deploy/01_peronio_deploy.ts
import hre from "hardhat";
import { getConstructorParams } from "../utils/helpers";
import { IPeronioConstructorParams } from "../utils/types/IPeronioConstructorParams";

module.exports = async () => {
  console.info("Deploying Peronio");
  const { getNamedAccounts, deployments } = hre;

  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const peronioConstructor: IPeronioConstructorParams = getConstructorParams();

  await deploy("Peronio", {
    contract: "Peronio",
    from: deployer,
    log: true,
    args: [
      peronioConstructor.name,
      peronioConstructor.symbol,
      peronioConstructor.usdcAddress,
      peronioConstructor.maiAddress,
      peronioConstructor.lpAddress,
      peronioConstructor.qiAddress,
      peronioConstructor.quickswapRouterAddress,
      peronioConstructor.qiFarmAddress,
      peronioConstructor.qiPoolId,
    ],
  });
};

module.exports.tags = ["Peronio"];
