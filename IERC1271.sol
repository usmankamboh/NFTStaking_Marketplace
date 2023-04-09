// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
interface IERC1271 {
    function isValidSignature(bytes32 _hash, bytes calldata _signature)  external view returns (bytes4 magicValue);
}