// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

import {Context} from "@openzeppelin/contracts_latest/utils/Context.sol";
import {Math} from "@openzeppelin/contracts_latest/utils/math/Math.sol";

import "./ICumpaFarm.sol";
import {Cumpa} from "./Cumpa.sol";
import "./Peronio.sol";

contract CumpaFarm is Context, ICumpaFarm {
    using EnumerableMap for EnumerableMap.AddressToUintMap;

    Peronio private peronio;
    Cumpa private cumpa;

    uint256 private totalCumpas;
    EnumerableMap.AddressToUintMap private cumpasByAddress;

    uint256 private frozenTotalCumpas;
    EnumerableMap.AddressToUintMap private frozenCumpasByAddress;

    mapping(address => uint256) public override rewardsByAddress;
    uint256 private totalRewards;



    function distribute() external override {
        uint256 tips = _collectedTips();

        uint256 length = frozenCumpasByAddress.length();

        address[] memory frozenAddresses = new address[](length);
        uint256[] memory frozenCumpaAmounts = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            (address to, uint256 cumpas) = frozenCumpasByAddress.at(i);
            frozenAddresses[i] = to;
            frozenCumpaAmounts[i] = cumpas;
        }

        uint256 rewards;
        for (uint256 i = 0; i < length; i++) {
            address to = frozenAddresses[i];
            uint cumpas = frozenCumpaAmounts[i];

            frozenCumpasByAddress.remove(to);

            uint256 reward = Math.mulDiv(tips, cumpas, frozenTotalCumpas);

            rewardsByAddress[to] += reward;
            rewards += reward;
        }
        totalRewards += rewards;

        uint256 newLength = cumpasByAddress.length();
        for (uint256 i = 0; i < newLength; i++) {
            (address to, uint256 cumpas) = cumpasByAddress.at(i);
            frozenCumpasByAddress.set(to, cumpas);
        }
        frozenTotalCumpas = totalCumpas;
    }

    function collectedTips() external view override returns (uint256 tips) {
        tips = _collectedTips();
    }

    function _collectedTips() internal view returns (uint256 tips) {
        tips = peronio.balanceOf(address(this)) - totalRewards;
    }

    function deposit(uint256 amount) external override {
        (, uint256 cumpas) = cumpasByAddress.tryGet(_msgSender());
        cumpasByAddress.set(_msgSender(), cumpas + amount);
        totalCumpas += amount;

        cumpa.transferFrom(_msgSender(), address(this), amount);

    }

    function withdraw(address to, uint256 amount) external override {
        (, uint256 cumpas) = cumpasByAddress.tryGet(_msgSender());
        require(amount <= cumpas, "CumpaFarm: not enough CUM");

        cumpa.transfer(to, amount);
        cumpasByAddress.set(_msgSender(), cumpas - amount);
        totalCumpas -= amount;
    }

    function extract(address to, uint256 amount) external override {
        uint256 rewards = rewardsByAddress[_msgSender()];
        require(amount <= rewards, "CumpaFarm: not enough rewards");

        rewardsByAddress[_msgSender()] -= amount;
        totalRewards -= amount;

        peronio.transfer(to, amount);
    }
}
