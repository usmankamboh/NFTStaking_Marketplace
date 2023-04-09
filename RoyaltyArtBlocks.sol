// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;
pragma abicoder v2;

import "./LibPart.sol";

abstract contract RoyaltyArtBlocks {
    
    function getRoyaltyData(uint256 _tokenId) external virtual view returns (address artistAddress, address additionalPayee, uint256 additionalPayeePercentage, uint256 royaltyFeeByID);

}
