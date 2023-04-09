// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma abicoder v2;
import "./IRoyaltiesProvider.sol";
import "./RoyaltyArtBlocks.sol";
import "./BpLibrary.sol";
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract RoyaltiesProviderArtBlocks is IRoyaltiesProvider, Ownable {
    using SafeMathUpgradeable for uint;
    using BpLibrary for uint;

    uint96 public artblocksPercentage = 250;

    event ArtblocksPercentageChanged(address _who, uint96 _old, uint96 _new);

    function getRoyalties(address token, uint tokenId) override external view returns(LibPart.Part[] memory) {

        RoyaltyArtBlocks artBlocks = RoyaltyArtBlocks(token);

        //gettign artist and additionalPayee royalty part
        (address artistAddress, address additionalPayee, uint256 additionalPayeePercentage, uint256 royaltyFeeByID) = artBlocks.getRoyaltyData(tokenId);

        require(additionalPayeePercentage <= 100 && royaltyFeeByID <= 100, "wrong royalties percentages from artBlocks");

        //resulting royalties
        LibPart.Part[] memory result;

        //if no artist royalty
        if (royaltyFeeByID == 0) {
            //if artblocksPercentage > 0
            if (artblocksPercentage > 0) {
                result = new LibPart.Part[](1);

                //calculating artBLocks part
                result[0].account = payable(owner());
                result[0].value = artblocksPercentage;
            }
            //if artblocksPercentage = 0 then result is empty
            return result;

        //if royaltyFeeByID > 0 and  0 < additionalPayeePercentage < 100
        } else if (additionalPayeePercentage > 0 && additionalPayeePercentage < 100) {
            result = new LibPart.Part[](3);

            //calculating artBLocks part
            result[0].account = payable(owner());
            result[0].value = artblocksPercentage;

             // additional payee percentage * 100
            uint96 additionalPart = uint96(royaltyFeeByID.mul(100).bp(additionalPayeePercentage.mul(100)));

            //artist part
            result[1].account = payable(artistAddress);
            result[1].value = uint96(royaltyFeeByID.mul(100).sub(additionalPart));

            result[2].account = payable(additionalPayee);
            result[2].value = additionalPart;
            
        //if royaltyFeeByID > 0 and additionalPayeePercentage == 0 or 100
        } else {
            result = new LibPart.Part[](2);

            //calculating artBLocks part
            result[0].account = payable(owner());
            result[0].value = artblocksPercentage;

            // additional payee percentage * 100
            uint96 additionalPart = uint96(royaltyFeeByID.mul(100).bp(additionalPayeePercentage.mul(100)));

            //artist part
            if (additionalPayeePercentage == 0) {
                result[1].account = payable(artistAddress);
                result[1].value = uint96(royaltyFeeByID.mul(100).sub(additionalPart));
            }

            //additional payee part
            if (additionalPayeePercentage == 100) {
                result[1].account = payable(additionalPayee);
                result[1].value = additionalPart;
            }
        } 

        return result;
    }

    //sets new value for artblocksPercentage
    function setArtblocksPercentage(uint96 _artblocksPercentage) onlyOwner public {
        require(_artblocksPercentage <= 10000,"_artblocksPercentage can't be > 100%");
        emit ArtblocksPercentageChanged(_msgSender(), artblocksPercentage, _artblocksPercentage);
        artblocksPercentage = _artblocksPercentage;
    }

}
