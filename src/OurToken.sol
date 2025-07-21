// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


contract OurToken is ERC20, Ownable {

    error NotZeroAddress();
    error ZeroAmount();
    error MustBeMoreThanZero();
    error BurnAmountExceedsBalance();

    constructor(uint256 initialSupply) ERC20("UsdtToken", "usdt") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
    }
    function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert NotZeroAddress();
        }
        if (_amount == 0) {
            revert ZeroAmount();
        }
        _mint(_to, _amount);
        return true;
    }

    function burn(uint256 _amount) external onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount == 0) {
            revert MustBeMoreThanZero();
        }
        if (balance < _amount) {
            revert BurnAmountExceedsBalance();
        }
        _burn(msg.sender, _amount);
    }
}
