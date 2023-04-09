// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma abicoder v2;
import "./LibERC721LazyMint.sol";
import "./LibPart.sol";
interface IERC165Upgradeable {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
interface IERC721Upgradeable is IERC165Upgradeable {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC721LazyMint is IERC721Upgradeable {

    event Creators(
        uint256 tokenId,
        LibPart.Part[] creators
    );

    function mintAndTransfer(
        LibERC721LazyMint.Mint721Data memory data,
        address to
    ) external;

    function transferFromOrMint(
        LibERC721LazyMint.Mint721Data memory data,
        address from,
        address to
    ) external;
}
