// SPDX-License-Identifier: MIT
 
pragma solidity ^0.8.24;

import {Test,console} from "forge-std/Test.sol";
import {ICO} from "src/ICO.sol";
import {OurToken} from "src/OurToken.sol";
import {MockPyth} from "lib/pyth-sdk-solidity/MockPyth.sol";
import {StdChains} from "forge-std/StdChains.sol";

contract IcoTest is StdChains, Test {

    ICO public ico;
    MockPyth public pyth;
    OurToken public ethToken;
    bytes32 ETH_PRICE_FEED_ID = bytes32(uint256(0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace));

    uint256 ETH_TO_WEI = 10e24; 
    // address owner = address(1);


    function setUp() public {    
        pyth = new MockPyth(60,1);
        ethToken = new OurToken(0);

        address[] memory tokenAddresses = new address[](1);
        tokenAddresses[0] = address(ethToken);

        bytes32[] memory priceFeedIds = new bytes32[](1);
        priceFeedIds[0] = ETH_PRICE_FEED_ID;

        // vm.prank(owner);
        ico = new ICO(
            tokenAddresses,
            priceFeedIds,
            address(pyth),
            msg.sender
        );
        // ico.transferOwnership(owner);

       
    }

    //////////////////
    // Price Tests //
    //////////////////

    function creactEthUpdate(
        int64 ethPrice
    ) private view returns(bytes[] memory) {
        bytes[] memory updateData = new bytes[](1);
        updateData[0] = pyth.createPriceFeedUpdateData(
            ETH_PRICE_FEED_ID,
            ethPrice * 10000,
            10 * 100000,
            -5,
            ethPrice * 10000,
            10 * 10000,
            uint64(block.timestamp)
        );
        return updateData;
    }

    function testSetEthPrice(int64 ethPrice) private {
        bytes[] memory updateData = creactEthUpdate(ethPrice); 
        uint value = pyth.getUpdateFee(updateData);
        vm.deal(address(this), value);
        pyth.updatePriceFeeds{ value: value }(updateData);
    }

    function testMintToken() public {
        testSetEthPrice(100);

        vm.deal(address(this), ETH_TO_WEI);
        vm.expectRevert();
        uint256 tokenAmount = 1000;
        ico.depositToContract{ value : ETH_TO_WEI / 100}(
            address(ethToken), 
            tokenAmount
        );
    }

     function testMintStalePrice() public {
        testSetEthPrice(100);

        skip(50);

        vm.deal(address(this), ETH_TO_WEI);
        ethToken.mint(address(this), 100000);
        ethToken.approve(address(ico), 10000);
        ico.depositToContract{ value : ETH_TO_WEI / 100}(
            address(ethToken), 
            100 
        );
     }

    //  function testWithdrawEthToken() public {
    //     testSetEthPrice(100);
    //     vm.deal(address(this), ETH_TO_WEI);

    //     ethToken.mint(address(this), 100000);

    //     ethToken.approve(address(ico), 10000);
    //     ico.depositToContract{ value : ETH_TO_WEI / 100}(
    //         address(ethToken), 
    //         100 
    //     );

    //     uint256 balanceBefore = ethToken.balanceOf(address(this));
    //     vm.prank(owner);
    //     ico.withdrawTokens(address(ethToken), 100);

    //     uint256 balanceAfter = ethToken.balanceOf(address(this));

    //     assertEq(balanceAfter, balanceBefore + 100);

    //  }
}   