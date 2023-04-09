// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;
library SignedSafeMathUpgradeable {
    function mul(int256 a, int256 b) internal pure returns (int256) {
        return a * b;
    }
    function div(int256 a, int256 b) internal pure returns (int256) {
        return a / b;
    }
    function sub(int256 a, int256 b) internal pure returns (int256) {
        return a - b;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        return a + b;
    }
}

library LibIntMapping {
    using SignedSafeMathUpgradeable for int;

    function addToItem(mapping(uint => int) storage map, uint key, int value) internal {
        map[key] = map[key].add(value);
    }

    function subFromItem(mapping(uint => int) storage map, uint key, int value) internal {
        map[key] = map[key].sub(value);
    }
}
