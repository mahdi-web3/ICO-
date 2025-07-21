// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {ICO} from "../src/ICO.sol";
import {OurToken} from "../src/OurToken.sol";

contract DeployIco is Script {
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    uint256 public constant INITAL_COIN = 100 ether;

    address public constant wethUsdPriceFeed = address(uint160(uint256(0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace))); // ETH/USD price feed
    address public constant weth = 0x2880aB155794e7179c9eE2e38200202908C17B43; //WETH token address

    function run() public returns (ICO, OurToken) {

        tokenAddresses = [weth];
        priceFeedAddresses = [wethUsdPriceFeed];

        vm.startBroadcast();
        OurToken usdtToken = new OurToken(INITAL_COIN);
        ICO ico = new ICO( tokenAddresses,priceFeedAddresses,address(usdtToken), msg.sender);
        usdtToken.transferOwnership(address(ico));
        vm.stopBroadcast();

        return (ico, usdtToken);
    }
}
