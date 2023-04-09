// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import "./LibRoyaltiesV1.sol";
import "./RoyaltiesV1.sol";
import "./Initializable.sol";
interface IERC165Upgradeable {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }
    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}
abstract contract RoyaltiesV1Upgradeable is ERC165Upgradeable, RoyaltiesV1 {
    function __RoyaltiesV1Upgradeable_init_unchained() internal initializer {
        supportsInterface(LibRoyaltiesV1._INTERFACE_ID_FEES);
    }
}
