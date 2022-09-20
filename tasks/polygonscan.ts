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
    const migratorAddress: Address = (await deployments.get("Migrator")).address;
    const autoCompounderAddress: Address = (await deployments.get("AutoCompounder")).address;
    const cumpaAddress: Address = (await deployments.get("Cumpa")).address;

    runVerify("Publishing Peronio to Polygonscan", peronioAddress, getConstructorParams());
    runVerify("Publishing Migrator to Polygonscan", migratorAddress, [peronioV1Address, peronioAddress]);
    runVerify("Publishing AutoCompounder to Polygonscan", autoCompounderAddress, { peronioAddress });
    runVerify("Publishing Cumpa to Polygonscan", cumpaAddress, { peronioAddress });
});
