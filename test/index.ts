import { expect } from "chai";
import { BigNumber } from "ethers";
import hre, { ethers } from "hardhat";
import { Peronio, ERC20 } from "../typechain";
import { IPeronioContructor } from "./types";

const peronioContructor: IPeronioContructor = {
  name: process.env.TOKEN_NAME ?? "",
  symbol: process.env.TOKEN_SYMBOL ?? "",
  usdcAddress: process.env.USDC_ADDRESS ?? "",
  maiAddress: process.env.MAI_ADDRESS ?? "",
  lpAddress: process.env.LP_ADDRESS ?? "",
  qiAddress: process.env.QI_ADDRESS ?? "",
  quickswapRouterAddress: process.env.QUICKSWAP_ROUTER_ADDRESS ?? "",
  qiFarmAddress: process.env.QIDAO_FARM_ADDRESS ?? "",
  qiPoolId: process.env.QIDAO_POOL_ID ?? "",
};

const peronioInitializer = {
  usdcAmount: 100,
  ratio: 250,
};

enum Roles {
  DEFAULT_ADMIN = "0x0000000000000000000000000000000000000000000000000000000000000000",
  MARKUP = "0x74a064b2dec4aeb0b53e2d06f8e76ce531a17302a866fe51bc86d9a90b4e85e3",
  REWARDS = "0x5407862f04286ebe607684514c14b7fffc750b6bf52ba44ea49569174845a5bd",
}

// START TESTS

describe("Peronio", function () {
  let contract: Peronio;
  let usdcContract: ERC20;
  let accounts: { [name: string]: string };

  // Setup
  before(async () => {
    accounts = await hre.getNamedAccounts();
  });

  // Load USDC Contract
  before(async () => {
    usdcContract = await ethers.getContractAt(
      "ERC20",
      process.env.USDC_ADDRESS ?? ""
    );
  });

  // Deploy Peronio
  before(async () => {
    contract = await deployPeronio(peronioContructor);
    await contract.deployed();
  });

  describe("Constructor variables", () => {
    it("should return correct USDC_ADDRESS", async function () {
      expect(await contract.USDC_ADDRESS()).to.equal(
        peronioContructor.usdcAddress
      );
    });

    it("should return correct MAI_ADDRESS", async function () {
      expect(await contract.MAI_ADDRESS()).to.equal(
        peronioContructor.maiAddress
      );
    });

    it("should return correct LP_ADDRESS", async function () {
      expect(await contract.LP_ADDRESS()).to.equal(peronioContructor.lpAddress);
    });

    it("should return correct QUICKSWAP_ROUTER_ADDRESS", async function () {
      expect(await contract.QUICKSWAP_ROUTER_ADDRESS()).to.equal(
        peronioContructor.quickswapRouterAddress
      );
    });

    it("should return correct QIDAO_FARM_ADDRESS", async function () {
      expect(await contract.QIDAO_FARM_ADDRESS()).to.equal(
        peronioContructor.qiFarmAddress
      );
    });

    it("should return correct QI_ADDRESS", async function () {
      expect(await contract.QI_ADDRESS()).to.equal(peronioContructor.qiAddress);
    });

    it("should return correct QIDAO_POOL_ID", async function () {
      expect(await contract.QIDAO_POOL_ID()).to.equal(
        peronioContructor.qiPoolId
      );
    });

    it("should return correct keccak256 MARKUP_ROLE", async function () {
      expect(await contract.MARKUP_ROLE()).to.equal(Roles.MARKUP);
    });

    it("should return correct keccak256 REWARDS_ROLE", async function () {
      expect(await contract.REWARDS_ROLE()).to.equal(Roles.REWARDS);
    });
  });

  describe("Markup", () => {
    it("should return 5 for MARKUP_DECIMALS", async function () {
      expect(await contract.MARKUP_DECIMALS()).to.equal(5);
    });

    it("should return 5000 for markup", async function () {
      expect(await contract.markup()).to.equal(5000);
    });

    it("should set 20000 for markup", async function () {
      const newMakup = 2000;
      await contract.setMarkup(newMakup);
      expect(await contract.markup()).to.equal(newMakup);
    });
  });

  describe("Initialization", () => {
    it("should return initialized=false when not initialized", async function () {
      const isInitialized = await contract.initialized();
      expect(isInitialized).to.equal(false);
    });

    it("should initialize", async function () {
      const initUsdcAmount = ethers.utils.parseUnits(
        peronioInitializer.usdcAmount.toString(),
        6
      );
      const initRatio = peronioInitializer.ratio;

      // Approve
      await usdcContract.approve(contract.address, initUsdcAmount);

      // Initialize
      await contract.initialize(initUsdcAmount, initRatio);
    });

    it("should return initialized true when initialized", async function () {
      const isInitialized = await contract.initialized();
      expect(isInitialized).to.equal(true);
    });

    const totalPE = peronioInitializer.usdcAmount * peronioInitializer.ratio;
    it(`should have PE ${totalPE} in balance`, async function () {
      // Initialize
      const balance = await contract.balanceOf(accounts.deployer);
      expect(balance).to.be.equal(
        ethers.utils.parseUnits(totalPE.toString(), 6)
      );
    });

    it("should return reservesValue more than 0", async function () {
      const reservesValue = await contract.reservesValue();
      expect(reservesValue).to.be.gt(BigNumber.from(0));
    });

    it("should return stakedBalance more than 0", async function () {
      const stakedBalance = await contract.stakedBalance();
      expect(stakedBalance.toNumber()).to.be.gt(BigNumber.from(0));
    });

    it("should return stakedValue more than 0", async function () {
      const stakedValue = await contract.stakedValue();
      expect(stakedValue.toNumber()).to.be.gt(BigNumber.from(0));
    });

    it("should revert when trying to initialize twice", async function () {
      // Initialize
      const initUsdcAmount = ethers.utils.parseUnits(
        peronioInitializer.usdcAmount.toString(),
        6
      );
      const initRatio = peronioInitializer.ratio;

      expect(contract.initialize(initUsdcAmount, initRatio)).to.be.revertedWith(
        "Contract already initialized"
      );
    });
  });

  describe("Roles", () => {
    // Deploy Peronio
    before(async () => {
      contract = await deployPeronio(peronioContructor);
      await contract.deployed();
    });

    it("should revert when setMarkup as not MARKUP_ROLE", async function () {
      expect(
        contract.connect(accounts.tester).setMarkup("5000")
      ).to.be.revertedWith(
        `AccessControl: account ${accounts.tester.toLowerCase()} is missing role ${
          Roles.MARKUP
        }`
      );
    });

    it("should revert when claimRewards as not REWARDS_ROLE", async function () {
      expect(
        contract.connect(accounts.tester).claimRewards()
      ).to.be.revertedWith(
        `AccessControl: account ${accounts.tester.toLowerCase()} is missing role ${
          Roles.REWARDS
        }`
      );
    });

    it("should revert when compoundRewards as not REWARDS_ROLE", async function () {
      expect(
        contract.connect(accounts.tester).compoundRewards()
      ).to.be.revertedWith(
        `AccessControl: account ${accounts.tester.toLowerCase()} is missing role ${
          Roles.REWARDS
        }`
      );
    });
  });

  describe("Deposit and Withdraw", () => {
    // Deploy Peronio
    before(async () => {
      contract = await deployPeronio(peronioContructor);
      await contract.deployed();
    });

    // Initialize Peronio
    before(async () => {
      const initUsdcAmount = ethers.utils.parseUnits(
        peronioInitializer.usdcAmount.toString(),
        6
      );
      const initRatio = peronioInitializer.ratio;

      // Approve
      await usdcContract.approve(contract.address, initUsdcAmount);

      // Initialize
      await contract.initialize(initUsdcAmount, initRatio);
    });

    it("should deposit USDC 1", async function () {
      const peOldBalance = await contract.balanceOf(accounts.deployer);
      const usdcOldBalance = await usdcContract.balanceOf(accounts.deployer);

      const amount = ethers.utils.parseUnits("1", 6);

      // Approve
      await usdcContract.approve(contract.address, amount);

      // Deposit
      await contract.deposit(accounts.deployer, amount);

      const peBalance = await contract.balanceOf(accounts.deployer);
      const usdcBalance = await usdcContract.balanceOf(accounts.deployer);
      const receivedPe = peBalance.sub(peOldBalance);
      const depositedUsdc = usdcOldBalance.sub(usdcBalance);

      expect(receivedPe).to.be.closeTo(
        BigNumber.from("235000000"),
        BigNumber.from("10000000")
      );

      expect(depositedUsdc).to.be.equal(amount);
    });

    it("should withdraw PE 250", async function () {
      const peOldBalance = await contract.balanceOf(accounts.deployer);
      const usdcOldBalance = await usdcContract.balanceOf(accounts.deployer);

      const amount = ethers.utils.parseUnits("250", 6);

      // Approve
      await contract.approve(contract.address, amount);

      // Deposit
      await contract.withdraw(accounts.deployer, amount);

      const peBalance = await contract.balanceOf(accounts.deployer);
      const usdcBalance = await usdcContract.balanceOf(accounts.deployer);
      const subtractedPe = peOldBalance.sub(peBalance);
      const receivedUsdc = usdcBalance.sub(usdcOldBalance);

      expect(subtractedPe).to.be.equal(amount);

      expect(receivedUsdc).to.be.closeTo(
        BigNumber.from("1000000"),
        BigNumber.from("100000")
      );
    });
  });
});

const deployPeronio = async (
  contructor: IPeronioContructor
): Promise<Peronio> => {
  const Peronio = await ethers.getContractFactory("Peronio");
  const contract = await Peronio.deploy(
    contructor.name,
    contructor.symbol,
    contructor.usdcAddress,
    contructor.maiAddress,
    contructor.lpAddress,
    contructor.qiAddress,
    contructor.quickswapRouterAddress,
    contructor.qiFarmAddress,
    contructor.qiPoolId
  );
  return contract;
};
