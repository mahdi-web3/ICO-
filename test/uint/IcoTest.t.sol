// SPDX-License-Identifier: MIT
 
pragma solidity ^0.8.24;

import {Test,console} from "forge-std/Test.sol";
import {ICO} from "src/ICO.sol";
import {OurToken} from "src/OurToken.sol";
import {MockUsdt} from "test/mocks/MockUsdt.sol";
import {ERC20Mock} from "test/mocks/ERC20Mock.sol";
import {DeployIco} from "script/DeployIco.s.sol";
import {MockPyth} from "test/mocks/MockPyth.sol";
import {StdChains} from "forge-std/StdChains.sol";

contract IcoTest is StdChains, Test {

    ICO public ico;
    OurToken public usdtToken;
    MockPyth public mockPyth;

    address public user = address(1);


    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    address public ethUsdPriceFeed;
    address public weth;
    function setUp() public {

        mockPyth = new MockPyth();
        wusdt = address(new ERC20Mock("Mock USDT", "mUSDT", address(this), 0));
        weth = address(new ERC20Mock("Mock WETH", "mWETH", address(this), 0));
        console.log("weth", weth);
        console.log("wusdt", wusdt);
        
        DeployIco deployer = new DeployIco();
        (ico, usdtToken) = deployer.run();
        
        mockPyth.setPrice(200000000000, wusdt); // set price for the correct token
        vm.deal(user, STARTING_USER_BALANCE);

        ERC20Mock(weth).mint(user, STARTING_USER_BALANCE);
        ERC20Mock(wusdt).mint(user, STARTING_USER_BALANCE);
    }

    ///////////////////////
    // Constructor Tests //
    ///////////////////////
    
    address [] public tokenAddress;
    address [] public feeAddress;

    function testRevertIfTokenAddressesAndPriceFeedAddressesAreNotSameLength() public {
        tokenAddress.push(weth);
        tokenAddress.push();
        feeAddress.push(ethUsdPriceFeed);
        vm.expectRevert(abi.encodeWithSelector(ICO.TokenAddressesAndPriceFeedAddressesMustBeSameLength.selector));
        new ICO(
            tokenAddress,
            feeAddress,
            address(usdtToken),
            msg.sender
        );
    }

    //////////////////
    // Price Tests //
    //////////////////

    function testGetTokenAmountFromUsd() public {

        uint256 expecetedWeth = 0.05 ether;
        uint256 amountWeth = ico.buyTokens(weth, 100 ether);
        assertEq(amountWeth, expecetedWeth);
    }
}   