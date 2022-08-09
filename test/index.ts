import { expect } from "chai";
import { BigNumber, ContractTransaction } from "ethers";
import { keccak256 } from "ethers/lib/utils";
import hre, { ethers } from "hardhat";

import { Peronio, ERC20, AutoCompounder } from "../typechain-types";

import { Peronio__factory } from "../typechain-types/factories/contracts/Peronio__factory";
import { AutoCompounder__factory } from "../typechain-types/factories/contracts/AutoCompounder__factory";

import { IPeronioConstructorParams } from "../utils/types/IPeronioConstructorParams";
import { IPeronioInitializeParams } from "../utils/types/IPeronioInitializeParams";

import { getConstructorParams, getInitializeParams } from "../utils/helpers";

const { parseUnits, formatUnits } = ethers.utils;

const MARKUP_ROLE: string = keccak256(new TextEncoder().encode("MARKUP_ROLE"));
const REWARDS_ROLE: string = keccak256(new TextEncoder().encode("REWARDS_ROLE"));


// --- Helpers ------------------------------------------------------------------------------------------------------------------------------------------------

const peronioConstructorParams: IPeronioConstructorParams = getConstructorParams();

const deployPeronio = async (
    constructor: IPeronioConstructorParams
): Promise<Peronio> => {
    const Peronio: Peronio__factory = await ethers.getContractFactory("Peronio");
    let contract: Peronio = await Peronio.deploy(
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
    await contract.deployed();
    return contract;
};


const peronioInitializeParams: IPeronioInitializeParams = getInitializeParams();

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
    return new Promise((resolve) => setTimeout(() => { resolve(null); }, ms));
};


// --- Tests --------------------------------------------------------------------------------------------------------------------------------------------------

describe("Peronio", function () {
    let accounts: { [name: string]: string };
    let usdcContract: ERC20;

    before(async () => {
        accounts = await hre.getNamedAccounts();
        usdcContract = await ethers.getContractAt("ERC20", process.env.USDC_ADDRESS ?? "");
    });

    describe("Constructor variables", () => {
        let contract: Peronio;

        before(async () => {
            contract = await deployPeronio(peronioConstructorParams);
        });

        it("should return correct usdcAddress", async function () {
            expect(
                await contract.usdcAddress()
            ).to.equal(
                peronioConstructorParams.usdcAddress
            );
        });

        it("should return correct maiAddress", async function () {
            expect(
                await contract.maiAddress()
            ).to.equal(
                peronioConstructorParams.maiAddress
            );
        });

        it("should return correct lpAddress", async function () {
            expect(
                await contract.lpAddress()
            ).to.equal(
                peronioConstructorParams.lpAddress
            );
        });

        it("should return correct quickSwapRouterAddress", async function () {
            expect(
                await contract.quickSwapRouterAddress()
            ).to.equal(
                peronioConstructorParams.quickswapRouterAddress
            );
        });

        it("should return correct qiDaoFarmAddress", async function () {
            expect(
                await contract.qiDaoFarmAddress()
            ).to.equal(
                peronioConstructorParams.qiFarmAddress
            );
        });

        it("should return correct qiAddress", async function () {
            expect(
                await contract.qiAddress()
            ).to.equal(
                peronioConstructorParams.qiAddress
            );
        });

        it("should return correct qiDaoPoolId", async function () {
            expect(
                await contract.qiDaoPoolId()
            ).to.equal(
                peronioConstructorParams.qiPoolId
            );
        });

        it("should return correct keccak256 MARKUP_ROLE", async function () {
            expect(
                await contract.MARKUP_ROLE()
            ).to.equal(
                MARKUP_ROLE
            );
        });

        it("should return correct keccak256 REWARDS_ROLE", async function () {
            expect(
                await contract.REWARDS_ROLE()
            ).to.equal(
                REWARDS_ROLE
            );
        });
    });

    describe("Mint and Withdraw", () => {
        let contract: Peronio;

        before(async () => {
            contract = await deployPeronio(peronioConstructorParams);
            await initializePeronio(usdcContract, contract, peronioInitializeParams);
        });

        it("should mint USDC 1", async function () {
            const peOldBalance: BigNumber = await contract.balanceOf(accounts.deployer);
            const usdcOldBalance: BigNumber = await usdcContract.balanceOf(accounts.deployer);

            const amount: BigNumber = parseUnits("1", 6);

            // Quote PE amount
            const quotedPe: BigNumber = await contract.quoteIn(amount);

            console.info("Quoted:", formatUnits(quotedPe, 6));

            // Approve
            await usdcContract.approve(contract.address, amount);

            // Mint
            const minReceive: BigNumber = parseUnits("235", 6);
            await contract.mint(accounts.deployer, amount, minReceive);

            const peBalance: BigNumber = await contract.balanceOf(accounts.deployer);
            const usdcBalance: BigNumber = await usdcContract.balanceOf(accounts.deployer);
            const receivedPe: BigNumber = peBalance.sub(peOldBalance);
            const mintedUsdc: BigNumber = usdcOldBalance.sub(usdcBalance);

            // Should transfer usdc exactly as provided
            expect(
                mintedUsdc
            ).to.equal(
                amount
            );

            // Should be quoted amount
            expect(
                receivedPe
            ).to.equal(
                quotedPe
            );
        });

        it("should withdraw PE 250", async function () {
            const peOldBalance: BigNumber = await contract.balanceOf(accounts.deployer);
            const usdcOldBalance: BigNumber = await usdcContract.balanceOf(accounts.deployer);

            const amount: BigNumber = parseUnits("250", 6);

            // Quote PE amount
            const quotedUSDC: BigNumber = await contract.quoteOut(amount);

            console.info("Quoted:", formatUnits(quotedUSDC, 6));

            // Approve
            await contract.approve(contract.address, amount);

            // Withdraw
            await contract.withdraw(accounts.deployer, amount);

            const peBalance: BigNumber = await contract.balanceOf(accounts.deployer);
            const usdcBalance: BigNumber = await usdcContract.balanceOf(accounts.deployer);
            const subtractedPe: BigNumber = peOldBalance.sub(peBalance);
            const receivedUsdc: BigNumber = usdcBalance.sub(usdcOldBalance);

            expect(
                subtractedPe
            ).to.equal(
                amount
            );
            // Should be quoted amount
            expect(
                receivedUsdc
            ).to.equal(
                quotedUSDC
            );
        });

        it("should revert on not enough received PE", async function () {
            const amount: BigNumber = parseUnits("1", 6);

            // Approve
            await usdcContract.approve(contract.address, amount);

            // Mint
            const minReceive: BigNumber = parseUnits("250", 6);
            const call: Promise<ContractTransaction> = contract.mint(accounts.deployer, amount, minReceive);

            expect(
                call
            ).to.be.revertedWith(
                "Minimum required not met"
            );
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
            expect(
                stakedBalance
            ).to.be.gt(
                BigNumber.from(0)
            );
        });

        it("should return stakedTokens close to USDC 50 and MAI 50", async function () {
            const { usdcAmount, maiAmount }: { usdcAmount: BigNumber; maiAmount: BigNumber } = await contract.stakedTokens();
            expect(
                usdcAmount
            ).to.be.closeTo(
                parseUnits("50", 6),
                parseUnits("0.5", 6)
            );
            expect(
                maiAmount
            ).to.be.closeTo(
                parseUnits("50", 18),
                parseUnits("0.5", 18)
            );
        });

        it("should return stakedValue similar to 100 with 1.5% margin", async function () {
            const stakedValue: BigNumber = await contract.stakedValue();
            expect(
                stakedValue
            ).to.be.closeTo(
                parseUnits("100", 6),
                parseUnits("1.5", 6)
            );
        });

        it("should return a buyingPrice near PE/USDC 0.004 (+5%)", async function () {
            const buyingPrice: BigNumber = await contract.buyingPrice();
            expect(
                buyingPrice
            ).to.equal(
                parseUnits("0.0042", 6)
            );
        });

        it("should return a collateralRatio near PE/USDC 0.004", async function () {
            const collateralRatio: BigNumber = await contract.collateralRatio();
            expect(
                collateralRatio
            ).to.equal(
                parseUnits("0.004", 6)
            );
        });
    });

    describe("Markup", () => {
        let contract: Peronio;

        before(async () => {
            contract = await deployPeronio(peronioConstructorParams);
            await initializePeronio(usdcContract, contract, peronioInitializeParams);
        });

        it("should return 5 for feeDecimals", async function () {
            expect(
                await contract.feeDecimals()
            ).to.equal(
                5
            );
        });

        it("should return 5000 for markup fee", async function () {
            expect(
                await contract.markupFee()
            ).to.equal(
                5000
            );
        });

        it("should set 20000 for markup fee", async function () {
            const newMarkupFee: BigNumber = BigNumber.from(2000);
            await contract.setMarkupFee(newMarkupFee);
            expect(
                await contract.markupFee()
            ).to.equal(
                newMarkupFee
            );
        });
    });

    describe("Initialization", () => {
        let contract: Peronio;

        before(async () => {
            contract = await deployPeronio(peronioConstructorParams);
        });

        it("should return initialized=false when not initialized", async function () {
            const isInitialized: Boolean = await contract.initialized();
            expect(
                isInitialized
            ).to.equal(
                false
            );
        });

        it("should initialize", async function () {
            await initializePeronio(usdcContract, contract, peronioInitializeParams);
        });

        it("should return initialized true when initialized", async function () {
            const isInitialized: Boolean = await contract.initialized();
            expect(
                isInitialized
            ).to.equal(
                true
            );
        });

        it("should revert when trying to initialize twice", async function () {
            // Initialize
            const initUsdcAmount: BigNumber = peronioInitializeParams.usdcAmount;
            const initRatio: BigNumber = peronioInitializeParams.startingRatio;

            expect(
                contract.initialize(initUsdcAmount, initRatio)
            ).to.be.revertedWith(
                "Contract already initialized"
            );
        });
    });

    describe("Roles", () => {
        let contract: Peronio;

        before(async () => {
            contract = await deployPeronio(peronioConstructorParams);
        });

        it("should revert when setMarkupFee as not MARKUP_ROLE", async function () {
            expect(
                contract.connect(accounts.tester).setMarkupFee("5000")
            ).to.be.revertedWith(
                `AccessControl: account ${accounts.tester.toLowerCase()} is missing role ${MARKUP_ROLE}`
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
        let contract: Peronio;

        before(async () => {
            contract = await deployPeronio(peronioConstructorParams);
            await initializePeronio(usdcContract, contract, peronioInitializeParams)
        });

        it("should compound rewards", async function () {
            await ethers.provider.send("evm_setIntervalMining", [20]);
            await ethers.provider.send("evm_setAutomine", [true]);

            // Wait 5 seconds
            await sleep(5000);

            // Stop Mining
            await ethers.provider.send("evm_setAutomine", [false]);

            expect(
                await contract.getPendingRewardsAmount()
            ).to.be.gt(
                0
            );

            await contract.compoundRewards();
        });

        it("should compound from AutoCompounder", async function () {
            // Deploys auto-compounder
            const AutoCompounder: AutoCompounder__factory = await ethers.getContractFactory("AutoCompounder");
            let autoCompounder: AutoCompounder = await AutoCompounder.deploy(contract.address);
            await autoCompounder.deployed();

            // Grants role
            await contract.grantRole(REWARDS_ROLE, autoCompounder.address);
        });
    });
});
