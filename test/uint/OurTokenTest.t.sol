//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {OurToken} from "src/OurToken.sol";

contract OutTokenTest is Test {
    OurToken public ourToken;

    address bob = makeAddr("Bob");
    address alice = makeAddr("Alice");

    uint256 public constant START_BALANCE = 100 ether;

    function setUp() public {
        //deployer = new DeployOurToken();
        //ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, START_BALANCE);
    }

    function testBobBalance() public view {
        assertEq(START_BALANCE, ourToken.balanceOf(bob));
    }

    function testAllowncesWork() public {
        uint256 initialAllowance = 1000;

        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), START_BALANCE - transferAmount);
    }
}
