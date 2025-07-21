// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import { ERC20Burnable, ERC20 } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract MockUsdt is ERC20, Ownable  {

    error NotZeroAddress();
    error ZeroAmount();
    error MustBeMoreThanZero();
    error BurnAmountExceedsBalance();

    constructor(address initialOwner) ERC20("Mock USDT", "USDT") Ownable(initialOwner) {}


        function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert NotZeroAddress();
        }
        if (_amount == 0) {
            revert ZeroAmount();
        }
        _mint(_to, _amount);

        return false;
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