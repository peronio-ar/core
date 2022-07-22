import { expect } from "chai";
import { BigNumber, ContractTransaction } from "ethers";
import { keccak256 } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";

import { Peronio, ERC20, AutoCompounder } from "../typechain";

import { IPeronioConstructorParams } from "../utils/types/iperonio_constructor_params";
import { IPeronioInitializeParams } from "../utils/types/iperonio_initialize_params";

import { getConstructorParams } from "../utils/helpers";

const { parseUnits, formatUnits } = ethers.utils;

const MARKUP_ROLE = keccak256(new TextEncoder().encode("MARKUP_ROLE"));
const REWARDS_ROLE = keccak256(new TextEncoder().encode("REWARDS_ROLE"));

const peronioConstructor: IPeronioConstructorParams = getConstructorParams();
const peronioInitializer: IPeronioInitializeParams = {
  usdcAmount: parseUnits("10", 6),
  startingRatio: 250,
};

// START TESTS

describe("Peronio", function () {
  let contract: Peronio;
  let autoCompounder: AutoCompounder;
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

  describe("Constructor variables", () => {
    // Deploy Peronio
    before(async () => {
      contract = await deployPeronio(peronioConstructor);
      await contract.deployed();
    });

    it("should return correct USDC_ADDRESS", async function () {
      expect(await contract.USDC_ADDRESS()).to.equal(
        peronioConstructor.usdcAddress
      );
    });

    it("should return correct MAI_ADDRESS", async function () {
      expect(await contract.MAI_ADDRESS()).to.equal(
        peronioConstructor.maiAddress
      );
    });

    it("should return correct LP_ADDRESS", async function () {
      expect(await contract.LP_ADDRESS()).to.equal(peronioConstructor.lpAddress);
    });

    it("should return correct QUICKSWAP_ROUTER_ADDRESS", async function () {
      expect(await contract.QUICKSWAP_ROUTER_ADDRESS()).to.equal(
        peronioConstructor.quickswapRouterAddress
      );
    });

    it("should return correct QIDAO_FARM_ADDRESS", async function () {
      expect(await contract.QIDAO_FARM_ADDRESS()).to.equal(
        peronioConstructor.qiFarmAddress
      );
    });

    it("should return correct QI_ADDRESS", async function () {
      expect(await contract.QI_ADDRESS()).to.equal(peronioConstructor.qiAddress);
    });

    it("should return correct QIDAO_POOL_ID", async function () {
      expect(await contract.QIDAO_POOL_ID()).to.equal(
        peronioConstructor.qiPoolId
      );
    });

    it("should return correct keccak256 MARKUP_ROLE", async function () {
      expect(await contract.MARKUP_ROLE()).to.equal(MARKUP_ROLE);
    });

    it("should return correct keccak256 REWARDS_ROLE", async function () {
      expect(await contract.REWARDS_ROLE()).to.equal(REWARDS_ROLE);
    });
  });

  describe("Mint and Withdraw", () => {
    // Deploy Peronio
    before(async () => {
      contract = await deployPeronio(peronioConstructor);
      await contract.deployed();
    });

    // Initialize Peronio
    before(async () => {
      // Initialize
      await initializePeronio(usdcContract, contract, peronioInitializer);
    });

    it("should mint USDC 1", async function () {
      const peOldBalance = await contract.balanceOf(accounts.deployer);
      const usdcOldBalance = await usdcContract.balanceOf(accounts.deployer);

      const amount = parseUnits("1", 6);

      // Quote PE amount
      const quotedPe = await contract.quoteIn(amount);

      console.info("Quoted:", formatUnits(quotedPe, 6));

      // Approve
      await usdcContract.approve(contract.address, amount);

      // Mint
      const minReceive = parseUnits("235", 6);
      await contract.mint(accounts.deployer, amount, minReceive);

      const peBalance = await contract.balanceOf(accounts.deployer);
      const usdcBalance = await usdcContract.balanceOf(accounts.deployer);
      const receivedPe = peBalance.sub(peOldBalance);
      const mintedUsdc = usdcOldBalance.sub(usdcBalance);

      // Should transfer usdc exactly as provided
      expect(mintedUsdc).to.be.equal(amount);

      // Should be quoted amount
      expect(receivedPe).to.be.equal(quotedPe);
    });

    it("should withdraw PE 250", async function () {
      const peOldBalance = await contract.balanceOf(accounts.deployer);
      const usdcOldBalance = await usdcContract.balanceOf(accounts.deployer);

      const amount = parseUnits("250", 6);

      // Quote PE amount
      const quotedUSDC = await contract.quoteOut(amount);

      console.info("Quoted:", formatUnits(quotedUSDC, 6));

      // Approve
      await contract.approve(contract.address, amount);

      // Withdraw
      await contract.withdraw(accounts.deployer, amount);

      const peBalance = await contract.balanceOf(accounts.deployer);
      const usdcBalance = await usdcContract.balanceOf(accounts.deployer);
      const subtractedPe = peOldBalance.sub(peBalance);
      const receivedUsdc = usdcBalance.sub(usdcOldBalance);

      expect(subtractedPe).to.be.equal(amount);
      expect(receivedUsdc).to.be.closeTo(
        parseUnits("1", 6),
        parseUnits("0.1", 6)
      );

      // Should be quoted amount
      expect(receivedUsdc).to.be.equal(quotedUSDC);
    });

    it("should revert on not enough received PE", async function () {
      const amount = parseUnits("1", 6);

      // Approve
      await usdcContract.approve(contract.address, amount);

      // Mint
      const minReceive = parseUnits("250", 6);
      const call = contract.mint(accounts.deployer, amount, minReceive);

      expect(call).to.be.revertedWith("Minimum required not met");
    });
  });

  describe("Quotes", () => {
    // Deploy Peronio
    before(async () => {
      contract = await deployPeronio(peronioConstructor);
      await contract.deployed();
    });

    const usdcAmount = parseUnits("100", 6);
    // Initialize Peronio
    before(async () => {
      // Initialize
      await initializePeronio(usdcContract, contract, {
        startingRatio: 250,
        usdcAmount,
      });
    });

    it("should return stakedBalance more than 0", async function () {
      const stakedBalance = await contract.stakedBalance();
      expect(stakedBalance).to.be.gt(BigNumber.from(0));
    });

    it("should return stakedTokens close to USDC 50 and MAI 50", async function () {
      const { usdcAmount, maiAmount } = await contract.stakedTokens();
      expect(usdcAmount).to.be.closeTo(
        parseUnits("50", 6),
        parseUnits("0.5", 6)
      );

      expect(maiAmount).to.be.closeTo(
        parseUnits("50", 18),
        parseUnits("0.5", 18)
      );
    });

    it("should return stakedValue similar to 100 with 1.5% margin", async function () {
      const stakedValue = await contract.stakedValue();
      expect(stakedValue).to.be.closeTo(
        parseUnits("100", 6),
        parseUnits("1.5", 6)
      );
    });

    it("should return a buyingPrice near PE/USDC 0.004 (+5%)", async function () {
      const buyingPrice = await contract.buyingPrice();
      expect(buyingPrice).to.equal(parseUnits("0.0042", 6));
    });

    it("should return a collateralRatio near PE/USDC 0.004", async function () {
      const collateralRatio = await contract.collateralRatio();
      expect(collateralRatio).to.equal(parseUnits("0.004", 6));
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
      const newMarkup = 2000;
      await contract.setMarkup(newMarkup);
      expect(await contract.markup()).to.equal(newMarkup);
    });
  });

  describe("Initialization", () => {
    // Deploy Peronio
    before(async () => {
      contract = await deployPeronio(peronioConstructor);
      await contract.deployed();
    });

    it("should return initialized=false when not initialized", async function () {
      const isInitialized = await contract.initialized();
      expect(isInitialized).to.equal(false);
    });

    it("should initialize", async function () {
      await initializePeronio(usdcContract, contract, peronioInitializer);
    });

    it("should return initialized true when initialized", async function () {
      const isInitialized = await contract.initialized();
      expect(isInitialized).to.equal(true);
    });

    it("should revert when trying to initialize twice", async function () {
      // Initialize
      const initUsdcAmount = peronioInitializer.usdcAmount;
      const initRatio = peronioInitializer.startingRatio;

      expect(contract.initialize(initUsdcAmount, initRatio)).to.be.revertedWith(
        "Contract already initialized"
      );
    });
  });

  describe("Roles", () => {
    // Deploy Peronio
    before(async () => {
      contract = await deployPeronio(peronioConstructor);
      await contract.deployed();
    });

    it("should revert when setMarkup as not MARKUP_ROLE", async function () {
      expect(
        contract.connect(accounts.tester).setMarkup("5000")
      ).to.be.revertedWith(
        `AccessControl: account ${accounts.tester.toLowerCase()} is missing role ${MARKUP_ROLE}`
      );
    });

    it("should revert when claimRewards as not REWARDS_ROLE", async function () {
      expect(
        contract.connect(accounts.tester).claimRewards()
      ).to.be.revertedWith(
        `AccessControl: account ${accounts.tester.toLowerCase()} is missing role ${REWARDS_ROLE}`
      );
    });

    it("should revert when compoundRewards as not REWARDS_ROLE", async function () {
      expect(
        contract.connect(accounts.tester).compoundRewards()
      ).to.be.revertedWith(
        `AccessControl: account ${accounts.tester.toLowerCase()} is missing role ${REWARDS_ROLE}`
      );
    });
  });

  describe("Auto Compounding + Rewards", () => {
    // Deploy Peronio and AutoCompounder
    before(async () => {
      contract = await deployPeronio(peronioConstructor);
      await contract.deployed();
    });

    const usdcAmount = parseUnits("10", 6);
    let blockNumber: number;

    // Initialize Peronio
    before(async () => {
      // Initialize
      blockNumber =
        (
          await initializePeronio(usdcContract, contract, {
            startingRatio: 250,
            usdcAmount,
          })
        ).blockNumber ?? 0;
    });

    it("should compound rewards", async function () {
      await ethers.provider.send("evm_setIntervalMining", [20]);
      await ethers.provider.send("evm_setAutomine", [true]);

      // Wait 5 seconds
      await sleep(5000);

      // Stop Mining
      await ethers.provider.send("evm_setAutomine", [false]);

      expect(await contract.getPendingRewardsAmount()).gt(BigNumber.from("0"));

      await contract.claimRewards();
      await contract.compoundRewards();
    });

    it("should compound from AutoCompounder", async function () {
      // Deploys autocompounder
      const AutoCompounder = await ethers.getContractFactory("AutoCompounder");
      autoCompounder = await AutoCompounder.deploy(contract.address);
      await autoCompounder.deployed();

      // Grants role
      await contract.grantRole(REWARDS_ROLE, autoCompounder.address);
    });
  });
});

const deployPeronio = async (
  constructor: IPeronioConstructorParams
): Promise<Peronio> => {
  const Peronio = await ethers.getContractFactory("Peronio");
  const contract = await Peronio.deploy(
    constructor.name,
    constructor.symbol,
    constructor.usdcAddress,
    constructor.maiAddress,
    constructor.lpAddress,
    constructor.qiAddress,
    constructor.quickswapRouterAddress,
    constructor.qiFarmAddress,
    constructor.qiPoolId
  );
  return contract;
};

const initializePeronio = async (
  usdcContract: ERC20,
  peContract: Peronio,
  params: IPeronioInitializeParams
): Promise<ContractTransaction> => {
  // Approve
  await usdcContract.approve(peContract.address, params.usdcAmount);

  // Initialize
  return peContract.initialize(params.usdcAmount, params.startingRatio);
};

const sleep = async (ms: number) => {
  return new Promise((resolve) =>
    setTimeout(() => {
      resolve(null);
    }, ms)
  );
};
