import { Address } from "hardhat-deploy/types";

export interface IPeronioConstructorParams {
    usdcAddress: Address;
    maiAddress: Address;
    lpAddress: Address;
    qiAddress: Address;
    quickswapRouterAddress: Address;
    qiFarmAddress: Address;
    qiPoolId: string;
}
