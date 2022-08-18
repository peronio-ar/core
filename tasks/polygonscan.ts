/* eslint-disable @typescript-eslint/no-unsafe-assignment */
/* eslint-disable @typescript-eslint/no-unsafe-call */

import { Address } from "hardhat-deploy/types";
import { task } from "hardhat/config";

import { getConstructorParams } from "../utils/helpers";

task("polygonscan", "Verify contract on Polyscan").setAction(async (_a, { network, deployments, getNamedAccounts, run }) => {
    if (network.name !== "matic") {
        console.warn(
            "You are running the faucet task with Hardhat network, which" +
                "gets automatically created and destroyed every time. Use the Hardhat" +
                " option '--network localhost'",
        );
    }

    async function runVerify(message: string, publishAddress: Address, args: object) {
        console.info(message);
        try {
            await run("verify:verify", { address: publishAddress, constructorArguments: Object.values(args) });
        } catch (e: any) {
            console.error(e.reason);
        }
    }

    const peronioAddress: Address = (await deployments.get("Peronio")).address;
    const peronioV1Address: Address = (await deployments.get("PeronioV1")).address;
    const peronioV1WrapperAddress: Address = (await deployments.get("PeronioV1Wrapper")).address;
    const migratorAddress: Address = (await deployments.get("Migrator")).address;
    const factoryAddress: Address = (await deployments.get("UniswapV2Factory")).address;
    const routerAddress: Address = (await deployments.get("UniswapV2Router02")).address;
    const autoCompounderAddress: Address = (await deployments.get("AutoCompounder")).address;
    const wmaticAddress: Address = process.env.WMATIC_ADDRESS ?? "";

    const { deployer } = await getNamedAccounts();

    runVerify("Publishing Peronio to Polygonscan", peronioAddress, getConstructorParams());
    runVerify("Publishing Peronio V1 Wrapper to Polygonscan", peronioV1WrapperAddress, [peronioV1Address]);
    runVerify("Publishing Migrator to Polygonscan", migratorAddress, [peronioV1WrapperAddress, peronioAddress]);
    runVerify("Publishing Uniswap Factory to Polygonscan", factoryAddress, { deployer });
    runVerify("Publishing Uniswap Router to Polygonscan", routerAddress, { factoryAddress, wmaticAddress });
    runVerify("Publishing AutoCompounder Polygonscan", autoCompounderAddress, { peronioAddress });
});
