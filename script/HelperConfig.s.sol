//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {MockV3Aggregator} from "../test/mocks/Mockv3Aggregator.sol";
import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    networkConfig public activeNetworkConfig;
    struct networkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getETHConfig();
        } else {
            activeNetworkConfig = getorCreateAnvilConfig();
        }
    }

    function getSepoliaConfig() public pure returns (networkConfig memory) {
        networkConfig memory SepoliaConfig = networkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return SepoliaConfig;
    }

    function getETHConfig() public pure returns (networkConfig memory) {
        networkConfig memory ETHConfig = networkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ETHConfig;
    }

    function getorCreateAnvilConfig() public returns (networkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        networkConfig memory AnvilConfig = networkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return AnvilConfig;
    }
}
