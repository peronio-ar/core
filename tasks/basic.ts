import { task } from "hardhat/config";
import { ERC20 } from "../typechain";
import { BalanceType } from "../types/utils";

task("check_balance", "Check current balance")
  .addOptionalParam("address", "Address")
  .setAction(async ({ address }, { getNamedAccounts, deployments, ethers }) => {
    const { deployer } = await getNamedAccounts();
    const addressToScan = address ?? deployer;

    const balances: BalanceType = {
      pe: ethers.BigNumber.from("0"),
      usdc: ethers.BigNumber.from("0"),
      matic: ethers.BigNumber.from("0"),
      wmatic: ethers.BigNumber.from("0"),
    };

    console.info("Address to scan:", addressToScan);

    console.info(
      "MATIC Balance:",
      ethers.utils.formatUnits(
        await ethers.provider.getBalance(addressToScan),
        18
      )
    );

    const usdcContract: ERC20 = await ethers.getContractAt(
      "ERC20",
      process.env.USDC_ADDRESS ?? ""
    );

    const wmaticContract: ERC20 = await ethers.getContractAt(
      "ERC20",
      process.env.WMATIC_ADDRESS ?? ""
    );

    balances.usdc = await usdcContract.balanceOf(addressToScan);
    console.info("USDC Balance:", ethers.utils.formatUnits(balances.usdc, 6));

    console.info(
      "WMATIC Balance:",
      ethers.utils.formatUnits(
        await wmaticContract.balanceOf(addressToScan),
        18
      )
    );

    try {
      const peronioDeployed = await deployments.get("Peronio");
      const peronioContract: ERC20 = await ethers.getContractAt(
        "ERC20",
        peronioDeployed.address
      );
      balances.pe = await peronioContract.balanceOf(addressToScan);
      console.info("PE Balance:", ethers.utils.formatUnits(balances.pe, 6));
    } catch (e) {
      console.info("Peronio not yet deployed");
    }

    return balances;
  });
