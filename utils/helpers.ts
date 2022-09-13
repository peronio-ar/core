import { BigNumber, ethers } from "ethers";

import { IPeronioConstructorParams } from "./interfaces/IPeronioConstructorParams";
import { IPeronioInitializeParams } from "./interfaces/IPeronioInitializeParams";

export function getConstructorParams(): IPeronioConstructorParams {
    return {
        usdcAddress: process.env.USDC_ADDRESS ?? "",
        maiAddress: process.env.MAI_ADDRESS ?? "",
        lpAddress: process.env.LP_ADDRESS ?? "",
        qiAddress: process.env.QI_ADDRESS ?? "",
        quickswapRouterAddress: process.env.QUICKSWAP_ROUTER_ADDRESS ?? "",
        qiFarmAddress: process.env.QIDAO_FARM_ADDRESS ?? "",
        qiPoolId: process.env.QIDAO_POOL_ID ?? "",
    };
}

export function getInitializeParams(): IPeronioInitializeParams {
    return {
        usdcAmount: ethers.utils.parseUnits(process.env.INIT_USDC_AMOUNT ?? "10", 6),
        startingRatio: ethers.utils.parseUnits(process.env.INIT_RATIO ?? "250", 6),
    };
}
