// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma abicoder v2;
import "./AuctionHouseBase1155.sol";
import "../ContextUpgradeable.sol";
import "../Initializable.sol";
interface IERC165Upgradeable {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
interface IERC1155Upgradeable is IERC165Upgradeable {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
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
interface IERC1155MetadataURIUpgradeable is IERC1155Upgradeable {
    function uri(uint256 id) external view returns (string memory);
}
contract ERC1155Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC1155Upgradeable, IERC1155MetadataURIUpgradeable {
    using AddressUpgradeable for address;
    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;
    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;
    function __ERC1155_init(string memory uri_) internal onlyInitializing {
        __ERC1155_init_unchained(uri_);
    }

    function __ERC1155_init_unchained(string memory uri_) internal onlyInitializing {
        _setURI(uri_);
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
    uint256[47] private __gap;
}

// contract to create and interact with auctions
contract AuctionHouse1155 is ERC1155Upgradeable, AuctionHouseBase1155 {
    using SafeMathUpgradeable96 for uint96;
    using SafeMathUpgradeable for uint;

    function __AuctionHouse1155_init(
        address newDefaultFeeReceiver,
        IRoyaltiesProvider newRoyaltiesProvider,
        address _transferProxy,
        address _erc20TransferProxy,
        uint64 newProtocolFee,
        uint96 _minimalStepBasePoint
    ) external initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
        __ERC1155Receiver_init_unchained();
        __ReentrancyGuard_init_unchained();
        __AuctionHouseBase_init_unchained(_minimalStepBasePoint);
        __TransferExecutor_init_unchained(_transferProxy, _erc20TransferProxy);
        __RaribleTransferManager_init_unchained(newProtocolFee, newDefaultFeeReceiver, newRoyaltiesProvider);        
        __AuctionHouse1155_init_unchained();
    }

    function __AuctionHouse1155_init_unchained() internal initializer {  
    }

    // creates an auction and locks sell asset
    function startAuction(
        address _sellToken,
        uint96 _sellTokenValue,
        uint _sellTokenId,
        address _buyAsset,
        uint96 minimalPrice,
        bytes4 dataType,
        bytes memory data
    ) external {
        //todo: check if token contract supports ERC1155 interface?

        uint _protocolFee = protocolFee;
        LibAucDataV1.DataV1 memory aucData = LibAucDataV1.parse(data, dataType);
        require(aucData.duration >= minimalDuration && aucData.duration <= MAX_DURATION, "incorrect duration");
        require(_sellTokenValue > 0, "incorrect _sellTokenValue");
        require(getValueFromData(aucData.originFee) + _protocolFee <= MAX_FEE_BASE_POINT, "wrong fees");

        uint currentAuctionId = getNextAndIncrementAuctionId();
        address payable sender = _msgSender();
        Auction memory auc = Auction(
            _sellToken,
            _sellTokenValue,
            _sellTokenId,
            _buyAsset,
            0,
            Bid(0, "", ""),
            sender,
            minimalPrice,
            payable(address(0)),
            uint64(_protocolFee),
            dataType,
            data
        );
        auctions[currentAuctionId] = auc;

        transferNFT(
            _sellToken, 
            _sellTokenId, 
            _sellTokenValue, 
            LibAsset.ERC1155_ASSET_CLASS,
            sender,
            address(this)
        );
        
        emit AuctionCreated(currentAuctionId, sender);
    }

    // put a bid and return locked assets for the last bid
    function putBid(uint _auctionId, Bid memory bid) payable public nonReentrant {
        address payable newBuyer = _msgSender();
        uint newAmount = bid.amount;
        Auction memory currentAuction = auctions[_auctionId];
        uint96 endTime = currentAuction.endTime;
        LibAucDataV1.DataV1 memory aucData = LibAucDataV1.parse(currentAuction.data, currentAuction.dataType);
        uint bidOriginFee = LibBidDataV1.parse(bid.data, bid.dataType).originFee;
        require(getValueFromData(aucData.originFee) + getValueFromData(bidOriginFee) + currentAuction.protocolFee <= MAX_FEE_BASE_POINT, "wrong fees");

        if (currentAuction.buyAsset == address(0)) {
            checkEthReturnChange(bid.amount, newBuyer);
        }
        checkAuctionInProgress(currentAuction.seller, currentAuction.endTime, aucData.startTime);
        if (buyOutVerify(aucData, newAmount)) {
            _buyOut(
                currentAuction,
                bid,
                aucData,
                _auctionId,
                bidOriginFee,
                newBuyer
            );
            return;
        }
        
        uint96 currentTime = uint96(block.timestamp);
        //start action if minimal price is met
        if (currentAuction.buyer == address(0x0)) {//no bid at all
            // set endTime if it's not set
            endTime = currentTime.add(aucData.duration);
            auctions[_auctionId].endTime = endTime;
            require(newAmount >= currentAuction.minimalPrice, "bid too small");
        } else {//there is bid in auction
            require(currentAuction.buyer != newBuyer, "already winning bid");
            uint256 minAmount = _getMinimalNextBid(currentAuction.buyer, currentAuction.minimalPrice, currentAuction.lastBid.amount);
            require(newAmount >= minAmount, "bid too low");
        }

        address proxy = _getProxy(currentAuction.buyAsset);
        reserveBid(
            currentAuction.buyAsset,
            currentAuction.buyer,
            newBuyer,
            currentAuction.lastBid,
            proxy,
            bid.amount
        );
        auctions[_auctionId].lastBid = bid;
        auctions[_auctionId].buyer = newBuyer;

        // auction is extended for EXTENSION_DURATION or minimalDuration if (minimalDuration < EXTENSION_DURATION)
        uint96 minDur = minimalDuration;
        uint96 extension = (minDur < EXTENSION_DURATION) ? minDur : EXTENSION_DURATION;

        // extends auction time if it's about to end
        if (endTime.sub(currentTime) < extension) {
            endTime = currentTime.add(extension);
            auctions[_auctionId].endTime = endTime;
        }
        emit BidPlaced(_auctionId, newBuyer, endTime);
    }

    // returns the minimal amount of the next bid (without fees)
    function getMinimalNextBid(uint _auctionId) external view returns (uint minBid){
        Auction memory currentAuction = auctions[_auctionId];
        return _getMinimalNextBid(currentAuction.buyer, currentAuction.minimalPrice, currentAuction.lastBid.amount);
    }

    // returns true if auction exists, false otherwise
    function checkAuctionExistence(uint _auctionId) external view returns (bool){
        return _checkAuctionExistence(auctions[_auctionId].seller);
    }

    // finishes, deletes and transfers all assets for an auction if it's ended (it exists, it has at least one bid, now > endTme)
    function finishAuction(uint _auctionId) external nonReentrant {
        Auction memory currentAuction = auctions[_auctionId];
        require(_checkAuctionExistence(currentAuction.seller), "there is no auction with this id");
        LibAucDataV1.DataV1 memory aucData = LibAucDataV1.parse(currentAuction.data, currentAuction.dataType);
        require(
            !_checkAuctionRangeTime(currentAuction.endTime, aucData.startTime) &&
            currentAuction.buyer != address(0),
            "only ended auction with bid can be finished"
        );
        uint bidOriginFee = LibBidDataV1.parse(currentAuction.lastBid.data, currentAuction.lastBid.dataType).originFee;

        doTransfers(
            LibDeal.DealSide(
                getSellAsset(
                    currentAuction.sellToken, 
                    currentAuction.sellTokenId,
                    currentAuction.sellTokenValue,
                    LibAsset.ERC1155_ASSET_CLASS
                ),
                getPayouts(currentAuction.seller),
                getOriginFee(aucData.originFee),
                proxies[LibAsset.ERC1155_ASSET_CLASS],
                address(this)
            ), 
            LibDeal.DealSide(
                getBuyAsset(
                    currentAuction.buyAsset,
                    currentAuction.lastBid.amount
                ),
                getPayouts(currentAuction.buyer),
                getOriginFee(bidOriginFee),
                _getProxy(currentAuction.buyAsset),
                address(this)
            ), 
            LibDeal.DealData(
                currentAuction.protocolFee,
                MAX_FEE_BASE_POINT,
                LibFeeSide.FeeSide.RIGHT
            )
        );
        deactivateAuction(_auctionId);
    }

    // returns true if auction started and hasn't finished yet, false otherwise
    function checkAuctionRangeTime(uint _auctionId) external view returns (bool){
        return _checkAuctionRangeTime(auctions[_auctionId].endTime, LibAucDataV1.parse(auctions[_auctionId].data, auctions[_auctionId].dataType).startTime);
    }

    // deletes auction after finalizing
    function deactivateAuction(uint _auctionId) internal {
        emit AuctionFinished(_auctionId);
        delete auctions[_auctionId];
    }

    // cancels existing auction without bid
    function cancel(uint _auctionId) external nonReentrant {
        Auction memory currentAuction = auctions[_auctionId];
        require(_checkAuctionExistence(currentAuction.seller), "there is no auction with this id");
        address seller = currentAuction.seller;
        require(seller == _msgSender(), "auction owner not detected");
        require(currentAuction.buyer == address(0), "can't cancel auction with bid");
        transferNFT(
            currentAuction.sellToken, 
            currentAuction.sellTokenId, 
            currentAuction.sellTokenValue, 
            LibAsset.ERC1155_ASSET_CLASS,
            address(this),
            seller
        );
        deactivateAuction(_auctionId);
        emit AuctionCancelled(_auctionId);
    }

    // todo will there be a problem if buyer is last bidder?
    // buyout auction if bid satisfies buyout condition
    function buyOut(uint _auctionId, Bid memory bid) external payable nonReentrant {
        Auction memory currentAuction = auctions[_auctionId];
        LibAucDataV1.DataV1 memory aucData = LibAucDataV1.parse(currentAuction.data, currentAuction.dataType);
        checkAuctionInProgress(currentAuction.seller, currentAuction.endTime, aucData.startTime);
        uint bidOriginFee = LibBidDataV1.parse(bid.data, bid.dataType).originFee;

        require(buyOutVerify(aucData, bid.amount), "not enough for buyout");
        require(getValueFromData(aucData.originFee) + getValueFromData(bidOriginFee) + currentAuction.protocolFee <= MAX_FEE_BASE_POINT, "wrong fees");

        address sender = _msgSender();
        if (currentAuction.buyAsset == address(0)) {
            checkEthReturnChange(bid.amount, sender);
        }
        _buyOut(
            currentAuction,
            bid,
            aucData,
            _auctionId,
            bidOriginFee,
            sender
        );
    }

    function _buyOut(
        Auction memory currentAuction,
        Bid memory bid,
        LibAucDataV1.DataV1 memory aucData,
        uint _auctionId,
        uint newBidOriginFee,
        address sender
    ) internal {
        address proxy = _getProxy(currentAuction.buyAsset);

        _returnBid(
            currentAuction.lastBid,
            currentAuction.buyAsset,
            currentAuction.buyer,
            proxy
        );

        address from;
        if (currentAuction.buyAsset == address(0)) {
            // if buyAsset = ETH
            from = address(this);
        } else {
            // if buyAsset = ERC20
            from = sender;
        }
        doTransfers(
            LibDeal.DealSide(
                getSellAsset(
                    currentAuction.sellToken, 
                    currentAuction.sellTokenId,
                    currentAuction.sellTokenValue,
                    LibAsset.ERC1155_ASSET_CLASS
                ),
                getPayouts(currentAuction.seller),
                getOriginFee(aucData.originFee),
                proxies[LibAsset.ERC1155_ASSET_CLASS],
                address(this)
            ), 
            LibDeal.DealSide(
                getBuyAsset(
                    currentAuction.buyAsset,
                    bid.amount
                ),
                getPayouts(sender),
                getOriginFee(newBidOriginFee),
                proxy,
                from
            ), 
            LibDeal.DealData(
                currentAuction.protocolFee,
                MAX_FEE_BASE_POINT,
                LibFeeSide.FeeSide.RIGHT
            )
        );
        
        deactivateAuction(_auctionId);
        emit AuctionBuyOut(auctionId, sender);
    }

    // returns current highest bidder for an auction
    function getCurrentBuyer(uint _auctionId) public view returns(address) {
        return auctions[_auctionId].buyer;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return this.supportsInterface(interfaceId);
    }

}