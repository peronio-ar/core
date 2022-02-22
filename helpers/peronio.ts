import { ethers } from "ethers";

import {
  IPeronioConstructorParams,
  IPeronioInitializeParams,
} from "../types/utils";

export function getConstructorParams() {
  const peronioContructor: IPeronioConstructorParams = {
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

  return peronioContructor;
}

export function getInitializeParams() {
  const peronioContructor: IPeronioInitializeParams = {
    usdcAmount: ethers.utils.parseUnits(
      process.env.INIT_USDC_AMOUNT ?? "10",
      6
    ),
    startingRatio: parseInt(process.env.INIT_RATIO ?? "250"),
  };

  return peronioContructor;
}
