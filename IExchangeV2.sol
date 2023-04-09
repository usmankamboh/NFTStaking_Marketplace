// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import "./LibOrder.sol";
contract IExchangeV2{
  function setAssetMatcher(bytes4 assetType, address matcher) external {
  } 
  function setTransferProxy(bytes4 assetType, address proxy) external {
  } 
  function matchOrders(
        LibOrder.Order memory orderLeft,
        bytes memory signatureLeft,
        LibOrder.Order memory orderRight,
        bytes memory signatureRight
    ) external payable;
}
