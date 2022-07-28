import { BigNumber } from "ethers";

export interface IPeronioInitializeParams {
    usdcAmount: BigNumber;
    startingRatio: number;
}
