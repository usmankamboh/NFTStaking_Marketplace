// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;
import "./LibPart.sol";
interface IERC2981 {
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (
        address receiver,
        uint256 royaltyAmount
    );
}