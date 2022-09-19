import hre from "hardhat";

/* eslint-disable no-unused-vars */
async function main() {
    /* eslint-enable no-unused-vars */
    console.info("Network:", hre.network.name);
    if (hre.network.name !== "matic") {
        console.info("Skipped Polygonscan and sourcify submission.");
    }
    await hre.run("polygonscan");
    await hre.run("sourcify");
    console.log("\u2705  Every contract has been successfully submitted to PolygonScan.");
}

main();
