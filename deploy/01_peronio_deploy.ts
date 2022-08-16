// deploy/01_peronio_deploy.ts
import hre from "hardhat";
import { getConstructorParams } from "../utils/helpers";

module.exports = async () => {
    console.info("Deploying Peronio");
    const { getNamedAccounts, deployments } = hre;

    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    await deploy("Peronio", {
        contract: "Peronio",
        from: deployer,
        log: true,
        args: Object.values(getConstructorParams()),
    });
};

module.exports.tags = ["Peronio"];
