import hre from "hardhat";

async function main() {
    console.info("Network:", hre.network.name);
    if (hre.network.name !== "matic") {
        console.info("Skipped Polygonscan and sourcify submission.");
        return;
    }
    await hre.run("polygonscan");
    await hre.run("sourcify");
    console.log(
        "\u2705  Every contract has been successfully submitted to PolygonScan."
    );
}

main().catch((error) => {
    throw error;
});
