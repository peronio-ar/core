// import { task } from "hardhat/config";
// import { ERC20, Peronio } from "../typechain";
// import { BalanceType } from "../types/utils";

// task("check_balance", "Check current balance")
//   .addOptionalParam("address", "Address")
//   .setAction(async ({ address }, { getNamedAccounts, deployments, ethers }) => {
//     const { deployer } = await getNamedAccounts();
//     const addressToScan = address ?? deployer;

//     const balances: BalanceType = {
//       pe: ethers.BigNumber.from("0"),
//       usdc: ethers.BigNumber.from("0"),
//       mai: ethers.BigNumber.from("0"),
//       matic: ethers.BigNumber.from("0"),
//       wmatic: ethers.BigNumber.from("0"),
//     };

//     console.info("Address to scan:", addressToScan);

//     console.info(
//       "MATIC Balance:",
//       ethers.utils.formatUnits(
//         await ethers.provider.getBalance(addressToScan),
//         18
//       )
//     );

//     const usdcContract: ERC20 = await ethers.getContractAt(
//       "ERC20",
//       process.env.USDC_ADDRESS ?? ""
//     );

//     const maiContract: ERC20 = await ethers.getContractAt(
//       "ERC20",
//       process.env.MAI_ADDRESS ?? ""
//     );

//     const wmaticContract: ERC20 = await ethers.getContractAt(
//       "ERC20",
//       process.env.WMATIC_ADDRESS ?? ""
//     );

//     balances.usdc = await usdcContract.balanceOf(addressToScan);
//     console.info("USDC Balance:", ethers.utils.formatUnits(balances.usdc, 6));

//     balances.mai = await maiContract.balanceOf(addressToScan);
//     console.info("MAI Balance:", ethers.utils.formatUnits(balances.mai, 18));

//     console.info(
//       "WMATIC Balance:",
//       ethers.utils.formatUnits(
//         await wmaticContract.balanceOf(addressToScan),
//         18
//       )
//     );

//     try {
//       const peronioDeployed = await deployments.get("Peronio");
//       const peronioContract: ERC20 = await ethers.getContractAt(
//         "ERC20",
//         peronioDeployed.address
//       );
//       balances.pe = await peronioContract.balanceOf(addressToScan);
//       console.info("PE Balance:", ethers.utils.formatUnits(balances.pe, 6));
//     } catch (e) {
//       console.info("Peronio not yet deployed");
//     }

//     return balances;
//   });

// task("withdraw", "Withdraw Peronio")
//   .addOptionalParam("pe", "PE to spend")
//   .setAction(async ({ pe }, { getNamedAccounts, ethers, deployments }) => {
//     const { deployer } = await getNamedAccounts();

//     const peAmount = pe ?? "250";

//     console.info("Amount to deposit", `PE ${peAmount}`);

//     const peronioAddress = (await deployments.get("Peronio")).address;
//     const peronioContract: Peronio = await ethers.getContractAt(
//       "Peronio",
//       peronioAddress
//     );

//     const collateralRatio = await peronioContract.collateralRatio();

//     console.info(
//       "collateral ratio: ",
//       ethers.utils.formatUnits(collateralRatio, 6)
//     );

//     const usdcAmount = ethers.utils
//       .parseUnits(peAmount, 6)
//       .mul(collateralRatio)
//       .div(ethers.BigNumber.from(Math.pow(10, 6)).toString());

//     console.info(
//       "USDC amount to receive ",
//       ethers.utils.formatUnits(usdcAmount, 6)
//     );

//     console.info(`Approving PE ${peAmount}...`);

//     await peronioContract.approve(
//       peronioAddress,
//       ethers.utils.parseUnits(peAmount, 6)
//     );

//     console.info("Withdrawing PE", peAmount);
//     await peronioContract.withdraw(
//       deployer,
//       ethers.utils.parseUnits(peAmount, 6)
//     );
//   });

// task("mint", "Mint Peronio")
//   .addOptionalParam("usdc", "USDC to spend")
//   .setAction(async ({ usdc }, { getNamedAccounts, ethers, deployments }) => {
//     const { deployer } = await getNamedAccounts();

//     const usdcAmount = usdc ?? "100";

//     console.info("Amount to deposit", `USDC ${usdcAmount}`);

//     const peronioAddress = (await deployments.get("Peronio")).address;
//     const usdcAddress = process.env.USDC_ADDRESS ?? "";

//     const peronioContract: Peronio = await ethers.getContractAt(
//       "Peronio",
//       peronioAddress
//     );

//     const usdcContract: ERC20 = await ethers.getContractAt(
//       "ERC20",
//       usdcAddress
//     );

//     console.info(`Approving USDC ${usdcAmount}...`);

//     await usdcContract.approve(
//       peronioAddress,
//       ethers.utils.parseUnits(usdcAmount, 6)
//     );

//     console.info("Minting USDC", usdcAmount);
//     await peronioContract.mint(
//       deployer,
//       ethers.utils.parseUnits(usdcAmount, 6),
//       ethers.utils.parseUnits("1", 6)
//     );
//   });
