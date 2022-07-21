const { BigNumber } = require("ethers");
const { getDeployedContract } = require("../utils");

task("deploy_peronio", "Deploy Peronio")
  // .addPositionalParam("address", "The address to check the balance from")
  .setAction(
    async ({ address }, { network, deployments, getNamedAccounts }) => {
      const { deploy } = deployments;
      const { deployer } = await getNamedAccounts();

      const routerAddress = getDeployedContract(
        "UniswapV2Router02",
        network.name
      ).address;

      const peronioContract = await deploy("Peronio", {
        contract: "Peronio",
        from: deployer,
        log: true,
        args: [
          process.env.TOKEN_NAME,
          process.env.TOKEN_SYMBOL,
          process.env.USDT_ADDRESS,
          process.env.AMUSDT_ADDRESS,
          process.env.AAVE_LENDING_POOL_ADDRESS,
          process.env.WMATIC_ADDRESS,
          routerAddress,
          process.env.AAVE_INCENTIVE_ADDRESS,
        ],
      });
      console.info("Deployed address", peronioContract.address);
    }
  );

task("init_peronio", "Initialize Peronio")
  // .addPositionalParam("address", "The address to check the balance from")
  .setAction(async ({ address }, { network }) => {
    const collateralAmount = "100"; // USDT 100
    const collateralRatio = "250"; // USDT 100

    const peronioAddress = getDeployedContract("Peronio", network.name).address;

    console.info("Peronio Address", peronioAddress);

    const peronioContract = await ethers.getContractAt(
      "Peronio",
      peronioAddress
    );

    console.info("Initializing contract");

    await peronioContract.initialize(
      ethers.utils.parseUnits(collateralAmount, 6),
      collateralRatio
    );

    console.info("Fully Initialized!");
  });

task("mint", "Mint Peronio")
  .addOptionalParam("usdt", "USDT to use")
  .setAction(async ({ usdt }, { getNamedAccounts, network }) => {
    const { deployer } = await getNamedAccounts();

    const usdtAmount = usdt ?? "100";

    console.info("Amount to deposit", `USDT ${usdtAmount}`);

    const peronioAddress = getDeployedContract("Peronio", network.name).address;
    const usdtAddress = process.env.USDT_ADDRESS;

    const peronioContract = await ethers.getContractAt(
      "Peronio",
      peronioAddress
    );
    const usdtContract = await ethers.getContractAt("ERC20", usdtAddress);

    const buyingPrice = await peronioContract.buyingPrice();

    console.info("buying price: ", ethers.utils.formatUnits(buyingPrice, 6));

    const peAmount = ethers.utils.parseUnits(usdtAmount, 12).div(buyingPrice);

    console.info("PE amount: ", ethers.utils.formatUnits(peAmount, 6));

    console.info(`Approving USDT ${usdtAmount}...`);
    console.info("usdtContract.address", usdtContract.address);

    await usdtContract.approve(
      peronioAddress,
      ethers.utils.parseUnits(usdtAmount, 6)
    );

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

    const peronioContract = await ethers.getContractAt(
      "Peronio",
      peronioAddress
    );

    const collateralRatio = await peronioContract.collateralRatio();

    console.info(
      "collateral ratio: ",
      ethers.utils.formatUnits(collateralRatio, 6)
    );

    const usdtAmount = ethers.utils
      .parseUnits(peAmount, 6)
      .mul(collateralRatio)
      .div(BigNumber.from(Math.pow(10, 6)).toString());

    console.info(
      "USDT amount to receive ",
      ethers.utils.formatUnits(usdtAmount, 6)
    );

    console.info(`Approving PE ${pe}...`);

    await peronioContract.approve(
      peronioAddress,
      ethers.utils.parseUnits(peAmount, 6)
    );

    console.info("Withdrawing PE", peAmount);
    await peronioContract.withdraw(
      deployer,
      ethers.utils.parseUnits(peAmount, 6)
    );
    console.info("Done!");
  });

task("harvest", "Harvest WMATIC and ZapIn").setAction(
  async ({}, { network }) => {
    // Get addresses
    const peronioAddress = getDeployedContract("Peronio", network.name).address;

    // Get contracts
    const peronioContract = await ethers.getContractAt(
      "Peronio",
      peronioAddress
    );

    console.dir(await peronioContract.harvestMaticIntoToken());
  }
);
