// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IPyth} from "lib/pyth-sdk-solidity/IPyth.sol";
import {PythStructs} from "lib/pyth-sdk-solidity/PythStructs.sol";

contract MockPyth {

    struct Price {
        int64 price;
        uint64 conf;
        int32 expo;
        uint64 publishTime;
    }

    mapping(bytes32 => Price) private mockPrices;

    error FailedOracleToGetPriceFromPyth();

    function setPrice(
        int64 price,
        bytes32 priceId
    ) external {
        mockPrices[priceId] = Price({
            price: price,
            conf: 0,
            expo: -8,
            publishTime: uint64(block.timestamp)
        });
    }

    function getPriceNoOlderThan(
        bytes32 priceId,
        uint256 maxAge
    ) external view returns (Price memory) {
        Price memory p = mockPrices[priceId];
        if (p.publishTime == 0) revert FailedOracleToGetPriceFromPyth();
        if (block.timestamp > p.publishTime + maxAge) revert FailedOracleToGetPriceFromPyth();
        return p;
    }
}
