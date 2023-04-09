// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import "./OwnableUpgradeable.sol";
abstract contract RaribleTransferManagerGap is OwnableUpgradeable {
      uint256[50] private ___gap;
}
abstract contract TransferExecutorGap is Initializable, OwnableUpgradeable {
      uint256[50] private ____gap;
}
