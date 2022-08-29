import { ChildProcess, exec, execSync } from "node:child_process";

import { expect } from "chai";
import { BigNumber, ContractTransaction } from "ethers";
import { keccak256 } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";

/* eslint-disable node/no-unpublished-import */
import { Peronio, ERC20, UniswapV2Router02, AutoCompounder, Migrator } from "../typechain-types";

import { Peronio__factory as PeronioFactory } from "../typechain-types/factories/contracts/Peronio__factory";
import { Migrator__factory as MigratorFactory } from "../typechain-types/factories/contracts/migrations/Migrator__factory";
import { AutoCompounder__factory as AutoCompounderFactory } from "../typechain-types/factories/contracts/AutoCompounder__factory";
/* eslint-enable node/no-unpublished-import */

import { IPeronioConstructorParams } from "../utils/interfaces/IPeronioConstructorParams";
import { IPeronioInitializeParams } from "../utils/interfaces/IPeronioInitializeParams";

import { getConstructorParams, getInitializeParams } from "../utils/helpers";
// eslint-disable-next-line node/no-unpublished-import
import { setBalance, mine } from "@nomicfoundation/hardhat-network-helpers";

const MARKUP_ROLE: string = keccak256(new TextEncoder().encode("MARKUP_ROLE"));
const REWARDS_ROLE: string = keccak256(new TextEncoder().encode("REWARDS_ROLE"));

// --- Helpers ------------------------------------------------------------------------------------------------------------------------------------------------

const peronioConstructorParams: IPeronioConstructorParams = getConstructorParams();

const deployPeronio = async (constructor: IPeronioConstructorParams): Promise<Peronio> => {
    const Peronio: PeronioFactory = await ethers.getContractFactory("Peronio");
    const contract: Peronio = await Peronio.deploy(
        constructor.name,
        constructor.symbol,
        constructor.usdcAddress,
        constructor.maiAddress,
        constructor.lpAddress,
        constructor.qiAddress,
        constructor.quickswapRouterAddress,
        constructor.qiFarmAddress,
        constructor.qiPoolId,
    );
    await contract.deployed();
    return contract;
};

const peronioInitializeParams: IPeronioInitializeParams = getInitializeParams();

const initializePeronio = async (usdcContract: ERC20, peContract: Peronio, params: IPeronioInitializeParams): Promise<ContractTransaction> => {
    // Approve
    await usdcContract.approve(peContract.address, params.usdcAmount);

    // Initialize
    return peContract.initialize(params.usdcAmount, params.startingRatio);
};

const swapMATICtoUSDC = async (
    uniswapContractAddress: string,
    wmaticAddress: string,
    usdcAddress: string,
    to: string,
    amount: string,
): Promise<ContractTransaction> => {
    const quickswapRouter: UniswapV2Router02 = await ethers.getContractAt("UniswapV2Router02", uniswapContractAddress);

    return await quickswapRouter.swapExactETHForTokens(BigNumber.from("1"), [wmaticAddress, usdcAddress], to, "9999999999999999999", {
        value: BigNumber.from(amount),
    });
};

// --- Tests --------------------------------------------------------------------------------------------------------------------------------------------------

describe("Peronio", function () {
    let accounts: { [name: string]: string };
    let usdcContract: ERC20;

    let childId: ChildProcess;

    before(async () => {
        childId = exec("nc -z localhost 8545 || yarn chain");
        execSync("while ! nc -z localhost 8545; do sleep 0.1; done");

        accounts = await hre.getNamedAccounts();
        usdcContract = await ethers.getContractAt("ERC20", process.env.USDC_ADDRESS ?? "");
    });

    after(() => {
        childId.kill();
    });

    before(async () => {
        // Mint MATIC to deployer account
        await setBalance(accounts.deployer, BigNumber.from("1000000000000000000000000000"));

        // Swap MATIC into USDC from QuickSwap Router
        await swapMATICtoUSDC(
            process.env.QUICKSWAP_ROUTER_ADDRESS ?? "",
            process.env.WMATIC_ADDRESS ?? "",
            process.env.USDC_ADDRESS ?? "",
            accounts.deployer,
            "10000000000000000000000000",
        );
    });

    describe("Constructor variables", () => {
        let contract: Peronio;

        before(async () => {
            contract = await deployPeronio(peronioConstructorParams);
        });

        it("should return correct keccak256 MARKUP_ROLE", async function () {
            expect(await contract.MARKUP_ROLE()).to.equal(MARKUP_ROLE);
        });

        it("should return correct keccak256 REWARDS_ROLE", async function () {
            expect(await contract.REWARDS_ROLE()).to.equal(REWARDS_ROLE);
        });

        it("should return correct usdcAddress", async function () {
            expect(await contract.usdcAddress()).to.equal(peronioConstructorParams.usdcAddress);
        });

        it("should return correct maiAddress", async function () {
            expect(await contract.maiAddress()).to.equal(peronioConstructorParams.maiAddress);
        });

        it("should return correct lpAddress", async function () {
            expect(await contract.lpAddress()).to.equal(peronioConstructorParams.lpAddress);
        });

        it("should return correct qiAddress", async function () {
            expect(await contract.qiAddress()).to.equal(peronioConstructorParams.qiAddress);
        });

        it("should return correct quickSwapRouterAddress", async function () {
            expect(await contract.quickSwapRouterAddress()).to.equal(peronioConstructorParams.quickswapRouterAddress);
        });

        it("should return correct qiDaoFarmAddress", async function () {
            expect(await contract.qiDaoFarmAddress()).to.equal(peronioConstructorParams.qiFarmAddress);
        });

        it("should return correct qiDaoPoolId", async function () {
            expect(await contract.qiDaoPoolId()).to.equal(peronioConstructorParams.qiPoolId);
        });
    });

    describe("Mint and Withdraw", () => {
        let contract: Peronio;

        before(async () => {
            contract = await deployPeronio(peronioConstructorParams);
            await initializePeronio(usdcContract, contract, peronioInitializeParams);
        });

        it("should mint USDC 1", async function () {
            const peBalanceOld: BigNumber = await contract.balanceOf(accounts.deployer);
            const usdcBalanceOld: BigNumber = await usdcContract.balanceOf(accounts.deployer);

            // Amount of USDCs to mint, expected PE amount, and minimum PEs to receive
            const amount: BigNumber = BigNumber.from(1_000000);
            const expectedPe: BigNumber = BigNumber.from(238_406705);
            const minReceive: BigNumber = BigNumber.from(235_000000);

            // Approve
            await usdcContract.approve(contract.address, amount);

            // Mint
            await contract.mint(accounts.deployer, amount, minReceive);

            const peBalance: BigNumber = await contract.balanceOf(accounts.deployer);
            const usdcBalance: BigNumber = await usdcContract.balanceOf(accounts.deployer);
            const receivedPe: BigNumber = peBalance.sub(peBalanceOld);
            const mintedUsdc: BigNumber = usdcBalanceOld.sub(usdcBalance);

            expect(mintedUsdc).to.equal(amount);
            expect(receivedPe).to.equal(expectedPe);
        });

        it("should withdraw PE 250", async function () {
            const peBalanceOld: BigNumber = await contract.balanceOf(accounts.deployer);
            const usdcBalanceOld: BigNumber = await usdcContract.balanceOf(accounts.deployer);

            // Amount of PEs to withdraw, and expected USDC amount
            const amount: BigNumber = BigNumber.from(250_000000);
            const quotedUSDC: BigNumber = BigNumber.from(1_000385);

            // Approve
            await contract.approve(contract.address, amount);

            // Withdraw
            await contract.withdraw(accounts.deployer, amount);

            const peBalance: BigNumber = await contract.balanceOf(accounts.deployer);
            const usdcBalance: BigNumber = await usdcContract.balanceOf(accounts.deployer);
            const withdrawnPe: BigNumber = peBalanceOld.sub(peBalance);
            const receivedUsdc: BigNumber = usdcBalance.sub(usdcBalanceOld);

            expect(withdrawnPe).to.equal(amount);
            expect(receivedUsdc).to.equal(quotedUSDC);
        });

        it("should revert on not enough received PE", async function () {
            const amount: BigNumber = BigNumber.from(1_000000);

            // Approve
            await usdcContract.approve(contract.address, amount);

            // Mint
            const minReceive: BigNumber = BigNumber.from(250_000000);
            const call: Promise<ContractTransaction> = contract.mint(accounts.deployer, amount, minReceive);

            expect(call).to.be.revertedWith("Minimum required not met");
        });

        it("should quote IN correctly", async function () {
            const peBalanceOld: BigNumber = await contract.balanceOf(accounts.deployer);
            const usdcBalanceOld: BigNumber = await usdcContract.balanceOf(accounts.deployer);

            // Amount of USDCs to mint, expected PE amount, and minimum PEs to receive
            const amount: BigNumber = BigNumber.from(1_000000);
            const expectedPe: BigNumber = await contract.quoteIn(1_000000);
            const minReceive: BigNumber = BigNumber.from(235_000000);

            // Approve
            await usdcContract.approve(contract.address, amount);

            // Mint
            await contract.mint(accounts.deployer, amount, minReceive);

            const peBalance: BigNumber = await contract.balanceOf(accounts.deployer);
            const usdcBalance: BigNumber = await usdcContract.balanceOf(accounts.deployer);
            const receivedPe: BigNumber = peBalance.sub(peBalanceOld);
            const mintedUsdc: BigNumber = usdcBalanceOld.sub(usdcBalance);

            expect(mintedUsdc).to.equal(amount);
            expect(receivedPe).to.equal(expectedPe);
        });

        it("should quote OUT correctly", async function () {
            const peBalanceOld: BigNumber = await contract.balanceOf(accounts.deployer);
            const usdcBalanceOld: BigNumber = await usdcContract.balanceOf(accounts.deployer);

            // Amount of PEs to withdraw, and expected USDC amount
            const amount: BigNumber = BigNumber.from(250_000000);
            const quotedUSDC: BigNumber = await contract.quoteOut(amount);

            // Approve
            await contract.approve(contract.address, amount);

            // Withdraw
            await contract.withdraw(accounts.deployer, amount);

            const peBalance: BigNumber = await contract.balanceOf(accounts.deployer);
            const usdcBalance: BigNumber = await usdcContract.balanceOf(accounts.deployer);

            const withdrawnPe: BigNumber = peBalanceOld.sub(peBalance);
            const receivedUsdc: BigNumber = usdcBalance.sub(usdcBalanceOld);

            expect(withdrawnPe).to.equal(amount);
            expect(receivedUsdc).to.equal(quotedUSDC);
        });
    });

    describe("Quotes", () => {
        let contract: Peronio;

        before(async () => {
            contract = await deployPeronio(peronioConstructorParams);
            await initializePeronio(usdcContract, contract, peronioInitializeParams);
        });

        it("should return stakedBalance more than 0", async function () {
            const stakedBalance: BigNumber = await contract.stakedBalance();
            expect(stakedBalance).to.be.gt(BigNumber.from(0));
        });

        it("should return stakedTokens close to USDC 50 and MAI 50", async function () {
            const { usdcAmount, maiAmount }: { usdcAmount: BigNumber; maiAmount: BigNumber } = await contract.stakedTokens();
            expect(usdcAmount).to.be.closeTo(BigNumber.from(50_000000), BigNumber.from(500000));
            expect(maiAmount.div(1_000000_000000)).to.be.closeTo(BigNumber.from(50_000000), BigNumber.from(500000));
        });

        it("should return stakedValue similar to 100 with 1.5% margin", async function () {
            const stakedValue: BigNumber = await contract.stakedValue();
            expect(stakedValue).to.be.closeTo(BigNumber.from(100_000000), BigNumber.from(1_500000));
        });

        it("should return a buyingPrice near PE/USDC 0.004 (+5%)", async function () {
            const buyingPrice: BigNumber = await contract.buyingPrice();
            expect(buyingPrice).to.equal(BigNumber.from(4200));
        });

        it("should return a collateralRatio near PE/USDC 0.004", async function () {
            const collateralRatio: BigNumber = await contract.collateralRatio();
            expect(collateralRatio).to.equal(BigNumber.from(4000));
        });
    });

    describe("Markup", () => {
        let contract: Peronio;

        before(async () => {
            contract = await deployPeronio(peronioConstructorParams);
            await initializePeronio(usdcContract, contract, peronioInitializeParams);
        });

        it("should return 6 for decimals", async function () {
            expect(await contract.decimals()).to.equal(6);
        });

        it("should return 50000 for markup fee", async function () {
            expect(await contract.markupFee()).to.equal(50000);
        });

        it("should set 20000 for markup fee", async function () {
            const newMarkupFee: BigNumber = BigNumber.from(20000);
            await contract.setMarkupFee(newMarkupFee);
            expect(await contract.markupFee()).to.equal(newMarkupFee);
        });
    });

    describe("Initialization", () => {
        let contract: Peronio;

        before(async () => {
            contract = await deployPeronio(peronioConstructorParams);
        });

        it("should return initialized=false when not initialized", async function () {
            const isInitialized: Boolean = await contract.initialized();
            expect(isInitialized).to.equal(false);
        });

        it("should initialize", async function () {
            await initializePeronio(usdcContract, contract, peronioInitializeParams);
        });

        it("should return initialized true when initialized", async function () {
            const isInitialized: Boolean = await contract.initialized();
            expect(isInitialized).to.equal(true);
        });

        it("should revert when trying to initialize twice", async function () {
            // Initialize
            const initUsdcAmount: BigNumber = peronioInitializeParams.usdcAmount;
            const initRatio: BigNumber = peronioInitializeParams.startingRatio;

            expect(contract.initialize(initUsdcAmount, initRatio)).to.be.revertedWith("Contract already initialized");
        });
    });

    describe("Roles", () => {
        let contract: Peronio;

        before(async () => {
            contract = await deployPeronio(peronioConstructorParams);
        });

        it("should revert when setMarkupFee as not MARKUP_ROLE", async function () {
            expect(contract.connect(accounts.tester).setMarkupFee("5000")).to.be.revertedWith(
                `AccessControl: account ${accounts.tester.toLowerCase()} is missing role ${MARKUP_ROLE}`,
            );
        });

        it("should revert when compoundRewards as not REWARDS_ROLE", async function () {
            expect(contract.connect(accounts.tester).compoundRewards()).to.be.revertedWith(
                `AccessControl: account ${accounts.tester.toLowerCase()} is missing role ${REWARDS_ROLE}`,
            );
        });
    });

    describe("Auto Compounding + Rewards", () => {
        let contract: Peronio;

        before(async () => {
            contract = await deployPeronio(peronioConstructorParams);
            await initializePeronio(usdcContract, contract, peronioInitializeParams);
        });

        it("should compound rewards", async function () {
            // Mine 250 Blocks
            await mine(250);

            expect(await contract.getPendingRewardsAmount()).to.be.gt(0);

            await contract.compoundRewards();
        });

        it("should compound from AutoCompounder", async function () {
            // Deploys auto-compounder
            const AutoCompounder: AutoCompounderFactory = await ethers.getContractFactory("AutoCompounder");
            const autoCompounder: AutoCompounder = await AutoCompounder.deploy(contract.address);
            await autoCompounder.deployed();

            // Grants role
            await contract.grantRole(REWARDS_ROLE, autoCompounder.address);
        });
    });

    describe("Migration", () => {
        let contract: Peronio;
        let oldContract: ERC20;
        let migrator: Migrator;

        before(async () => {
            const peronioV1Address = process.env.PERONIO_V1_ADDRESS || "";
            const Migrator: MigratorFactory = await ethers.getContractFactory("Migrator");
            const peronioV1 = await ethers.getContractAt("IPeronioV1", peronioV1Address);
            oldContract = await ethers.getContractAt("ERC20", peronioV1Address);

            contract = await deployPeronio(peronioConstructorParams);
            await initializePeronio(usdcContract, contract, peronioInitializeParams);

            migrator = await Migrator.deploy(peronioV1Address, contract.address);

            // Mint Peronio V1 tokens
            await usdcContract.approve(peronioV1Address, BigNumber.from(1000_000000));
            await peronioV1.mint(accounts.deployer, BigNumber.from(1000_000000), "1");
        });

        it("migrate 1 PE(v1) to PE(v2)", async function () {
            // Approve PE v1 for Migration contract
            const peV1Amount = BigNumber.from(250_000000);
            await oldContract.approve(migrator.address, peV1Amount);

            // Save initial balance for future comparison
            const peV1BalanceOld: BigNumber = await oldContract.balanceOf(accounts.deployer);
            const peV2BalanceOld: BigNumber = await contract.balanceOf(accounts.deployer);

            const { pe: quotedPE, usdc: quotedUSDC } = await migrator.quote(peV1Amount);

            // Simulate migration to get return
            const { pe: migratedPe, usdc: migratedUSDC } = await migrator.callStatic.migrate(peV1Amount);

            // Quote
            expect(quotedPE).to.equal(migratedPe);
            expect(quotedUSDC).to.equal(migratedUSDC);

            await migrator.migrate(peV1Amount);

            // Calculate current balance
            const peV1BalanceNew: BigNumber = await oldContract.balanceOf(accounts.deployer);
            const peV2BalanceNew: BigNumber = await contract.balanceOf(accounts.deployer);

            // Difference
            const withdrawnPeV1: BigNumber = peV1BalanceOld.sub(peV1BalanceNew);
            const receivedPeV2: BigNumber = peV2BalanceNew.sub(peV2BalanceOld);

            // Migrated proper amount
            expect(withdrawnPeV1).to.equal(peV1Amount);
            expect(receivedPeV2).to.equal(migratedPe);
        });
    });
});
