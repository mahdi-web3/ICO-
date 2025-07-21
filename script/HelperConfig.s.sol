// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {ERC20Mock} from "../test/mocks/ERC20Mock.sol";
import {MockPyth} from "../test/mocks/MockPyth.sol";

contract HelperConfig is Script {

    struct NetworkConfig {
        address wethUsdPriceFeed; // ETH/USD
        address weth;
        uint256 deployerKey;
    }

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant ETH_USD_PRICE = 2000e8;

    uint256 public DEFAULT_ANVIL_PRIVATEKEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;


    constructor() {
        if(block.chainid == 11155111) {
            activeNetworkConfig =getTestnetEthConfig();   
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getTestnetEthConfig() public view returns(NetworkConfig memory sepoliaNetworkConfig) {
        sepoliaNetworkConfig = NetworkConfig ({
            wethUsdPriceFeed : 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace,
            weth : 0x4305FB66699C3B2702D4d05CF36551390A4c69C6,
            deployerKey : 0 // or use vm.envUint("PRIVATE_KEY") if available
        });
    }

    
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory anvilNetworkConfig) {
            if (activeNetworkConfig.wethUsdPriceFeed != address(0)) {
                return activeNetworkConfig;
            }

            vm.startBroadcast();
            MockPyth ethUSdPriceFeed = new MockPyth(
                DECIMALS,
                ETH_USD_PRICE
            );
            ERC20Mock  wethMock = new ERC20Mock("ETH","WETH",msg.sender,1000e8);
            vm.stopBroadcast();

            anvilNetworkConfig = NetworkConfig ({
                wethUsdPriceFeed: address(ethUSdPriceFeed),
                weth: address(wethMock),
                deployerKey : DEFAULT_ANVIL_PRIVATEKEY
            });
    }
}