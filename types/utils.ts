import ethers, { BigNumber } from "ethers";

export interface IPeronioConstructorParams {
  name: string;
  symbol: string;
  usdcAddress: string;
  maiAddress: string;
  lpAddress: string;
  qiAddress: string;
  quickswapRouterAddress: string;
  qiFarmAddress: string;
  qiPoolId: string;
}

export interface IPeronioInitializeParams {
  usdcAmount: ethers.BigNumber;
  startingRatio: number;
}

export interface BalanceType {
  pe: BigNumber;
  usdc: BigNumber;
  mai: BigNumber;
  matic: BigNumber;
  wmatic: BigNumber;
}
