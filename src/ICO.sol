// SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.24;


import {OurToken} from "./OurToken.sol";
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IPyth} from  "lib/pyth-sdk-solidity/IPyth.sol";
import {PythStructs} from "lib/pyth-sdk-solidity/PythStructs.sol";
 
 

contract ICO is ReentrancyGuard, Ownable {

    /*error*/
    error NeedsMoreThanZero();
    error TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error TokenNotAllowed(address token);
    error TransferFailed();
    error AmountFailed();

    ///////////////////
    //State variables//
    ///////////////////
    /// @dev Mapping of token address to price feed address. 
    mapping(address token => address priceFeed) private pricefeedsIds;
    mapping(address user => mapping(address token => uint256 amount)) private usdtDeposit;

    address[] private s_UsdtTokens;
    
    OurToken private immutable usdtToken;
    IPyth private immutable pyth;
    uint256 public constant USDT_DECIMALS = 1e6; // 1 usdt = 1000000
    uint256 public constant ETH_DECIMALS = 1e18;

    event UsdtDeposit(address indexed user, address indexed token, uint256 amount);
    event TokensBought(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 ethAmount
    );
    event TokensRedeemed(address indexed user, address indexed token, uint256 indexed amount);
    ///////////////////
    //   Modifier   //
    ///////////////////

    modifier moreThanZero(uint256 amount){
        if (amount == 0) {
            revert NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token){
        if (pricefeedsIds[token] == address(0)) {
            revert TokenNotAllowed(token);
        }
        _;
    }


    ///////////////////
    //   Functions   //
    ///////////////////

    constructor(
        address [] memory tokenAddress,
        address [] memory priceFeedsAddress,
        address usdtTokenAddress,
        address initialOwner
    ) Ownable(initialOwner) {
        if(tokenAddress.length != priceFeedsAddress.length) {
            revert TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }
        for (uint256 i = 0; i < tokenAddress.length; i++) {
            pricefeedsIds[tokenAddress[i]] = priceFeedsAddress[i];
            s_UsdtTokens.push(tokenAddress[i]);
        }   
        usdtToken = OurToken(usdtTokenAddress);
    }

    ////////////////////////
    //   External Function//
    ////////////////////////

    function depositToContract(
        address usdtTokenAddress,
        uint256 amountToken
    ) external 
    moreThanZero(amountToken)
    isAllowedToken(usdtTokenAddress) 
    nonReentrant onlyOwner {
        usdtDeposit[msg.sender][usdtTokenAddress] += amountToken;
        emit UsdtDeposit(msg.sender, usdtTokenAddress, amountToken);

        bool success = IERC20(usdtTokenAddress).transferFrom(msg.sender, address(this), amountToken);
        if (!success) {
            revert TransferFailed();
        }
    }
    
    function buyTokens(
        address usdtTokenAddress,
        uint256 usdtAmount
        ) external
        moreThanZero(usdtAmount)
        nonReentrant onlyOwner returns (uint256) {  
        
        PythStructs.Price memory price = pyth.getPriceNoOlderThan(
            bytes32(uint256(uint160(pricefeedsIds[usdtTokenAddress]))),
            300
        );
        int64 exactPrice = price.price; //3006.08

        // int256 ethPrice = int256(exactPrice) * 1e18;
        uint256 ethAmount = (usdtAmount * 1e12) / uint256(uint64(exactPrice));
        emit TokensBought(
            msg.sender,
            usdtTokenAddress,
            usdtAmount,
            ethAmount
        );

        usdtDeposit[msg.sender][usdtTokenAddress] -= usdtAmount;
        bool success = IERC20(usdtTokenAddress).transfer(msg.sender, usdtAmount);
        if (!success) {
            revert TransferFailed();
        }
        return ethAmount;
    }

        function redeemTokens(
            address usdtTokenAddress, uint256 amountToken
            ) external
            moreThanZero(amountToken)
            nonReentrant onlyOwner {
            usdtDeposit[msg.sender][usdtTokenAddress] -= amountToken;
            emit TokensRedeemed(msg.sender, usdtTokenAddress, amountToken);

            bool success = IERC20(usdtTokenAddress).transfer(msg.sender, amountToken);
            if (!success) {
            revert TransferFailed();    
        }
    }
}
