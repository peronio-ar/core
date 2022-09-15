import * as dotenv from "dotenv";

import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "hardhat-deploy";

import "./tasks/polygonscan";
import "./tasks/preprocess";

dotenv.config();

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const GAS_PRICE = parseFloat(process.env.GAS_PRICE || "1");

const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY ?? "";
const MAINNET_API_URL = process.env.MAINNET_API_URL ?? "";

const PRIVATE_KEY = process.env.PRIVATE_KEY ?? "";
const TESTER_PRIVATE_KEY = process.env.TESTER_PRIVATE_KEY ?? "";

const ACCOUNTS = [PRIVATE_KEY, TESTER_PRIVATE_KEY];

const config: HardhatUserConfig = {
    defaultNetwork: "localhost",
    solidity: {
        compilers: [
            {
                version: "0.8.17",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 2000,
                        details: {
                            peephole: true,
                            inliner: true,
                            jumpdestRemover: true,
                            orderLiterals: true,
                            deduplicate: true,
                            cse: true,
                            constantOptimizer: true,
                            yul: true,
                            yulDetails: {
                                stackAllocation: true,
                            },
                        },
                    },
                },
            },
        ],
    },
    networks: {
        hardhat: {
            chainId: 137,
            forking: {
                url: MAINNET_API_URL,
                blockNumber: 32121120,
            },
            mining: {
                auto: true,
            },
        },
        localhost: {
            chainId: 137,
            url: "http://localhost:8545",
            accounts: ACCOUNTS,
        },
        matic: {
            chainId: 137,
            url: MAINNET_API_URL,
            gasPrice: GAS_PRICE * 10 ** 9,
            accounts: ACCOUNTS,
        },
        frame: {
            chainId: 137,
            url: "http://localhost:1248",
            gasPrice: GAS_PRICE * 10 ** 9,
            accounts: ACCOUNTS,
        },
    },
    gasReporter: {
        enabled: process.env.REPORT_GAS !== undefined,
        currency: "USD",
    },
    etherscan: {
        apiKey: ETHERSCAN_API_KEY,
    },
    namedAccounts: {
        deployer: {
            default: 0, // here this will by default take the first account as deployer
        },
        tester: {
            default: 1,
        },
    },
};

export default config;
