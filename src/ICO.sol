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
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IPyth} from  "lib/pyth-sdk-solidity/IPyth.sol";
import {PythStructs} from "lib/pyth-sdk-solidity/PythStructs.sol";
import {MockPyth} from "lib/pyth-sdk-solidity/MockPyth.sol";
import {console2} from "forge-std/Test.sol";
 
 

contract ICO is ReentrancyGuard, Ownable {

    /*error*/
    error NeedsMoreThanZero();
    error TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error TokenNotAllowed(address token);
    error TransferFailed();
    error AmountFailed();
    error InsufficientFee();

    ///////////////////
    //State variables//
    ///////////////////
    /// @dev Mapping of token address to price feed address. 
    mapping(address token => bytes32 priceFeed) private pricefeedsIds;
    mapping(address user => mapping(address token => uint256 amount)) private usdtDeposit;
    mapping(address user => uint256 amountTokenMinted) private s_TokenMinted;

    address[] private s_UsdtTokens;
    
    OurToken private immutable usdtToken;
    IPyth private immutable pyth;
    MockPyth private immutable mockPyth;
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
        if (pricefeedsIds[token] == bytes32(0)) {
            revert TokenNotAllowed(token);
        }
        _;
    }


    ///////////////////
    //   Functions   //
    ///////////////////

    constructor(
        address [] memory tokenAddress,
        bytes32 [] memory _ethUsdPriceId,
        address _pyth,
        address initialOwner
    ) Ownable(initialOwner) {
        if(tokenAddress.length != _ethUsdPriceId.length) {
            revert TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }

        for (uint256 i = 0; i < tokenAddress.length; i++) {
            pricefeedsIds[tokenAddress[i]] = _ethUsdPriceId[i];
        }
        pyth = IPyth(_pyth);
        usdtToken = OurToken(tokenAddress[0]);
    }

    ////////////////////////
    //   External Function//
    ////////////////////////

    function depositToContract(
        address token,
        uint256 amountToken
    ) external 
    payable
    moreThanZero(amountToken)
    isAllowedToken(token) 
    nonReentrant {
        bytes32 priceFeedId = pricefeedsIds[token];
        PythStructs.Price memory price = pyth.getPriceNoOlderThan(
            priceFeedId,
            60
        );
        uint ethPrice18Decimals = (uint(uint64(price.price)) * (10 ** 18)) /
            10 ** uint8(uint32(-1 * price.expo));
        uint oneDollarInWei = ((10 ** 18) * (10 ** 18)) / ethPrice18Decimals;

        console2.log("required payment in wei");
        console2.log(oneDollarInWei);

        if (msg.value >= oneDollarInWei) {
            usdtDeposit[msg.sender][token] += amountToken;
            emit UsdtDeposit(msg.sender, token, amountToken);
            IERC20(token).transferFrom(msg.sender, address(this), amountToken);
        } else {
            revert InsufficientFee();
        }
    }

        function withdrawTokens(
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
        receive() external payable {}
}