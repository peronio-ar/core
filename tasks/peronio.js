import { BigNumber } from "ethers";
import { getDeployedContract } from "../utils";
import { getConstructorParams } from "../utils/helpers";

task("deploy_peronio", "Deploy Peronio")
    // .addPositionalParam("address", "The address to check the balance from")
    .setAction(
        async ({ address }, { network, deployments, getNamedAccounts }) => {
            const { deploy } = deployments;
            const { deployer } = await getNamedAccounts();

            const peronioContract = await deploy(
                "Peronio",
                {
                    contract: "Peronio",
                    from: deployer,
                    log: true,
                    args: getConstructorParams(),
                }
            );
            console.info("Deployed address", peronioContract.address);
        }
    );

task("init_peronio", "Initialize Peronio")
    // .addPositionalParam("address", "The address to check the balance from")
    .setAction(async ({ address }, { network }) => {
        const collateralAmount = "100"; // USDC 100
        const collateralRatio = "250"; // USDC 100

        const peronioAddress = getDeployedContract("Peronio", network.name).address;
        console.info("Peronio Address", peronioAddress);

        console.info("Initializing contract");
        const peronioContract = await ethers.getContractAt("Peronio", peronioAddress);
        await peronioContract.initialize(ethers.utils.parseUnits(collateralAmount, 6), collateralRatio);

        console.info("Fully Initialized!");
    });

task("mint", "Mint Peronio")
    .addOptionalParam("usdc", "USDc to use")
    .setAction(async ({ usdc }, { getNamedAccounts, network }) => {
        const { deployer } = await getNamedAccounts();

        const usdcAmount = usdc ?? "100";

        console.info("Amount to deposit", `USDC ${usdcAmount}`);

        const peronioAddress = getDeployedContract("Peronio", network.name).address;
        const usdcAddress = process.env.USDC_ADDRESS;

        const peronioContract = await ethers.getContractAt("Peronio", peronioAddress);
        const usdcContract = await ethers.getContractAt("ERC20", usdcAddress);

        const buyingPrice = await peronioContract.buyingPrice();

        console.info("buying price: ", ethers.utils.formatUnits(buyingPrice, 6));

        const peAmount = ethers.utils.parseUnits(usdcAmount, 12).div(buyingPrice);

        console.info("PE amount: ", ethers.utils.formatUnits(peAmount, 6));

        console.info(`Approving USDC ${usdcAmount}...`);
        console.info("usdcContract.address", usdcContract.address);

        await usdcContract.approve(peronioAddress, ethers.utils.parseUnits(usdcAmount, 6));

        console.info("- Minting PE", ethers.utils.formatUnits(peAmount, 6));
        await peronioContract.mint(deployer, peAmount);
        console.info("Done!");
    });

task("withdraw", "Withdraw Peronio")
    .addOptionalParam("pe", "PE to spend")
    .setAction(async ({ pe }, { getNamedAccounts, network }) => {
        const { deployer } = await getNamedAccounts();

        const peAmount = pe ?? "250";
        console.info("Amount to deposit", `PE ${peAmount}`);

        const peronioAddress = getDeployedContract("Peronio", network.name).address;
        const peronioContract = await ethers.getContractAt("Peronio", peronioAddress);

        const collateralRatio = await peronioContract.collateralRatio();
        console.info("collateral ratio: ", ethers.utils.formatUnits(collateralRatio, 6));

        const usdcAmount = ethers.utils
            .parseUnits(peAmount, 6)
            .mul(collateralRatio)
            .div(BigNumber.from(Math.pow(10, 6)).toString());
        console.info("USDC amount to receive ", ethers.utils.formatUnits(usdcAmount, 6));

        console.info(`Approving PE ${pe}...`);
        await peronioContract.approve(peronioAddress, ethers.utils.parseUnits(peAmount, 6));

        console.info("Withdrawing PE", peAmount);
        await peronioContract.withdraw(deployer, ethers.utils.parseUnits(peAmount, 6));

        console.info("Done!");
    });

task("harvest", "Harvest WMATIC and ZapIn").setAction(
    async ({}, { network }) => {
        // Get addresses
        const peronioAddress = getDeployedContract("Peronio", network.name).address;

        // Get contracts
        const peronioContract = await ethers.getContractAt("Peronio", peronioAddress);

        console.dir(await peronioContract.harvestMaticIntoToken());
    }
);
