// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {ICO} from "../src/ICO.sol";
import {OurToken} from "../src/OurToken.sol";
import {ERC20Mock} from "../test/mocks/ERC20Mock.sol";
contract DeployIco is Script {
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    ERC20Mock public erc20Mock; 

    uint256 public constant INITAL_COIN = 100 ether;

    // function run() public returns (ICO, OurToken) {
    //     uint256 deployerKey = vm.envUint("PRIVATE_KEY");
    //     vm.startBroadcast(deployerKey);
        
    //     // OurToken usdtToken = new OurToken(INITAL_COIN);
    //     // ICO ico = new ICO( tokenAddresses,priceFeedAddresses,address(usdtToken), msg.sender);
    //     // usdtToken.transferOwnership(address(ico));
    //     vm.stopBroadcast();

    //     return (ico, usdtToken);
    // }
}
