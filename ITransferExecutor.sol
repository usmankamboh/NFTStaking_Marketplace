// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma abicoder v2;
import "./LibAsset.sol";
abstract contract ITransferExecutor {
    function transfer(
        LibAsset.Asset memory asset,
        address from,
        address to,
        address proxy
    ) internal virtual;
}
