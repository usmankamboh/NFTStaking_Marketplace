// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
library SafeMathUpgradeable96 {
    function add(uint96 a, uint96 b) internal pure returns (uint96) {
        uint96 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint96 a, uint96 b) internal pure returns (uint96) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
}