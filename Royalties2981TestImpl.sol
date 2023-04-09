// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;
pragma abicoder v2;

import "./IERC2981.sol";
import "./LibRoyalties2981.sol";
import "./LibPart.sol";

contract Royalties2981TestImpl is IERC2981 {
    uint public royaltiesBasePoint;

    function setRoyalties(uint _value) public {
        royaltiesBasePoint = _value;
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) override external view returns (address receiver, uint256 royaltyAmount) {
        receiver = address(uint160(_tokenId >> 96));
        royaltyAmount = (_salePrice * royaltiesBasePoint) / 10000;
    }

    function calculateRoyaltiesTest(address payable to, uint96 amount) external pure returns (LibPart.Part[] memory) {
        return LibRoyalties2981.calculateRoyalties(to, amount);
    }
}
