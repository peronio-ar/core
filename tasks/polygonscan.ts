/* eslint-disable @typescript-eslint/no-unsafe-assignment */
/* eslint-disable @typescript-eslint/no-unsafe-call */

import { task } from "hardhat/config";
import { getConstructorParams } from "../utils/helpers";

task("polygonscan", "Verify contract on Polyscan").setAction(
    async (_a, { network, deployments, getNamedAccounts, run }) => {
        if (network.name !== "matic") {
            console.warn(
                "You are running the faucet task with Hardhat network, which" +
                "gets automatically created and destroyed every time. Use the Hardhat" +
                " option '--network localhost'"
            );
        }

        const peronioAddress = (await deployments.get("Peronio")).address;
        const factoryAddress = (await deployments.get("UniswapV2Factory")).address;
        const routerAddress = (await deployments.get("UniswapV2Router02")).address;
        const autoCompounderAddress = (await deployments.get("AutoCompounder")).address;

        const wmaticAddress = process.env.WMATIC_ADDRESS;

        const { deployer } = await getNamedAccounts();

        console.info("Publishing Peronio to Polygonscan");
        try {
            await run("verify:verify", {
                address: peronioAddress,
                constructorArguments: getConstructorParams(),
            });
        } catch (e: any) {
            console.error(e.reason);
        }

        console.info("Publishing Uniswap Factory to Polygonscan");
        try {
            await run("verify:verify", {
                address: factoryAddress,
                constructorArguments: [deployer],
            });
        } catch (e: any) {
            console.error(e.reason);
        }

        console.info("Publishing Uniswap Router to Polygonscan");
        try {
            await run("verify:verify", {
                address: routerAddress,
                constructorArguments: [factoryAddress, wmaticAddress],
            });
        } catch (e: any) {
            console.error(e.reason);
        }

        console.info("Publishing AutoCompounder Polygonscan");
        try {
            await run("verify:verify", {
                address: autoCompounderAddress,
                constructorArguments: [peronioAddress],
            });
        } catch (e: any) {
            console.error(e.reason);
        }
    }
);
