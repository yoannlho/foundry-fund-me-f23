// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{

    NetworkConfig public ActiveNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            ActiveNetworkConfig = getSepoliaEthConfig();
        } else {
            ActiveNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // Price Feed Address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    // Just copy the getSepoliaEthConfig function and change the price feed address to the one you want to use

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (ActiveNetworkConfig.priceFeed != address(0)) {
            return ActiveNetworkConfig;
        }
 
        // Price Feed Address
        vm.startBroadcast();
        MockV3Aggregator mockpriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast(); 

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockpriceFeed)
        });
        return anvilConfig;
    }
}