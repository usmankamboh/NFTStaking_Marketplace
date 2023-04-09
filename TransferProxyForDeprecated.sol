// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;
pragma abicoder v2;

import "./OperatorRole.sol";
import "./ITransferProxy.sol";
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
contract TransferProxyForDeprecated is Initializable, OperatorRole, ITransferProxy {
    bytes4 constant public ERC721_DEP_ASSET_TYPE = bytes4(keccak256("ERC721_DEP"));

    function __TransferProxyForDeprecated_init() external initializer {
        __Ownable_init();
    }

    function transfer(LibAsset.Asset memory asset, address from, address to) override external onlyOperator {
        require(asset.assetType.assetClass == ERC721_DEP_ASSET_TYPE, "not supported asset type");
        require(asset.value == 1, "value validation error");
        (address token, uint tokenId) = abi.decode(asset.assetType.data, (address, uint));
        IERC721Upgradeable(token).transferFrom(from, to, tokenId);
    }
}