// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.7.0 <0.9.0;

/**
 * @dev ERC20 Contract Implementation
 *
 * Some parts written in Yul to reduce code size
 */
contract ERC20 {
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    uint256 internal _totalSupply;
    string private constant _name = 'Doom Cult Society DAO';
    string private constant _symbol = 'CUL';
    bytes32 internal constant TRANSFER_SIG = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;
    event Transfer(address indexed from, address indexed to, uint256 value);

    bytes32 internal constant APPROVAL_SIG = 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {}

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256 result) {
        assembly {
            mstore(0x00, owner)
            mstore(0x20, _allowances.slot)
            mstore(0x20, keccak256(0x00, 0x40))
            mstore(0x00, spender)
            result := sload(keccak256(0x00, 0x40))
        }
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance;
        assembly {
            // currentAllowance = _allowances[sender][msg.sender]
            mstore(0x00, sender)
            mstore(0x20, _allowances.slot)
            mstore(0x20, keccak256(0x00, 0x40))
            mstore(0x00, caller())
            let currentAllowanceSlot := keccak256(0x00, 0x40)
            currentAllowance := sload(currentAllowanceSlot)
            if gt(amount, currentAllowance) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x04, 0x20)
                mstore(0x24, 40)
                mstore(0x44, 'ERC20: transfer amount exceeds a')
                mstore(0x64, 'llowance')
                revert(0x00, 0x84)
            }
        }
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        assembly {
            if or(iszero(sender), iszero(recipient)) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x04, 0x20)
                mstore(0x24, 37)
                mstore(0x44, 'ERC20: transfer from the zero ad')
                mstore(0x64, 'dress')
                revert(0x00, 0x84)
            }

            mstore(0x00, sender)
            mstore(0x20, _balances.slot)
            let balancesSlot := keccak256(0x00, 0x40)
            let senderBalance := sload(balancesSlot)

            if gt(amount, senderBalance) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x04, 0x20)
                mstore(0x24, 38)
                mstore(0x44, 'ERC20: transfer amount exceeds b')
                mstore(0x64, 'alance')
                revert(0x00, 0x84)
            }

            sstore(balancesSlot, sub(senderBalance, amount))
            mstore(0x00, amount)
            log3(0x00, 0x20, TRANSFER_SIG, sender, recipient)
        }
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        assembly {
            if or(iszero(owner), iszero(spender)) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x04, 0x20)
                mstore(0x24, 36)
                mstore(0x44, 'ERC20: approve from the zero add')
                mstore(0x64, 'ress')
                revert(0x00, 0x84)
            }

            // _allowances[owner][spender] = amount
            mstore(0x00, owner)
            mstore(0x20, _allowances.slot)
            mstore(0x20, keccak256(0x00, 0x40))
            mstore(0x00, spender)
            sstore(keccak256(0x00, 0x40), amount)

            // emit Approval(owner, spender, amount)
            mstore(0x00, amount)
            log3(0x00, 0x20, APPROVAL_SIG, owner, spender)
        }
    }
}

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension and the Enumerable extension
 *
 * Some parts written in Yul to reduce code
 */
contract ERC721Enumerable is IERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    // Token name
    string private constant _name = 'Doom Cult Society';

    // Token symbol
    string private constant _symbol = 'DED';

    // event signatures
    uint256 private constant APPROVAL_FOR_ALL_SIG = 0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31;
    bytes32 internal constant TRANSFER_SIG = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;
    bytes32 internal constant APPROVAL_SIG = 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor() {}

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721Enumerable).interfaceId;
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256 res) {
        assembly {
            if iszero(owner) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x04, 0x20)
                mstore(0x24, 42)
                mstore(0x44, 'ERC721: balance query for the ze')
                mstore(0x64, 'ro address')
                revert(0x00, 0x84)
            }

            mstore(0x00, owner)
            mstore(0x20, _balances.slot)
            res := sload(keccak256(0x00, 0x40))
        }
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address owner) {
        assembly {
            mstore(0x00, tokenId)
            mstore(0x20, _owners.slot)
            // no need to mask address if we ensure everything written into _owners is an address
            owner := sload(keccak256(0x00, 0x40))

            if iszero(owner) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x04, 0x20)
                mstore(0x24, 41)
                mstore(0x44, 'ERC721: owner query for nonexist')
                mstore(0x64, 'ent token')
                revert(0x00, 0x84)
            }
        }
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256) public view virtual override returns (string memory) {
        return '';
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return '';
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);

        assembly {
            if eq(to, owner) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x04, 0x20)
                mstore(0x24, 33)
                mstore(0x44, 'ERC721: approval to current owne')
                mstore(0x64, 'r')
                revert(0x00, 0x84)
            }
        }
        bool approvedForAll = isApprovedForAll(owner, msg.sender);
        assembly {
            if iszero(or(eq(caller(), owner), approvedForAll)) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x04, 0x20)
                mstore(0x24, 55)
                mstore(0x44, 'ERC721: approve caller is not ow')
                mstore(0x64, 'er not approved for all')
                revert(0x00, 0x84)
            }
        }

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address res) {
        assembly {
            mstore(0x00, tokenId)
            mstore(0x20, _owners.slot)
            if iszero(sload(keccak256(0x00, 0x40))) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x04, 0x20)
                mstore(0x24, 44)
                mstore(0x44, 'ERC721: approved query for nonex')
                mstore(0x64, 'istent token')
                revert(0x00, 0x84)
            }

            mstore(0x00, tokenId)
            mstore(0x20, _tokenApprovals.slot)
            res := sload(keccak256(0x00, 0x40))
        }
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        assembly {
            if eq(operator, caller()) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x04, 0x20)
                mstore(0x24, 25)
                mstore(0x44, 'ERC721: approve to caller')
                revert(0x00, 0x64)
            }

            mstore(0x00, caller())
            mstore(0x20, _operatorApprovals.slot)
            mstore(0x20, keccak256(0x00, 0x40))
            mstore(0x00, operator)
            sstore(keccak256(0x00, 0x40), approved)

            log4(0, 0, APPROVAL_FOR_ALL_SIG, caller(), operator, approved)
        }
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool res) {
        assembly {
            mstore(0x00, owner)
            mstore(0x20, _operatorApprovals.slot)
            mstore(0x20, keccak256(0x00, 0x40))
            mstore(0x00, operator)
            res := sload(keccak256(0x00, 0x40))
        }
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        _isApprovedOrOwner(msg.sender, tokenId);
        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, '');
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        _isApprovedOrOwner(msg.sender, tokenId);
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), 'ERC721: transfer to non ERC721Receiver implementer');
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual {
        assembly {
            mstore(0x00, tokenId)
            mstore(0x20, _owners.slot)
            if iszero(sload(keccak256(0x00, 0x40))) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x04, 0x20)
                mstore(0x24, 44)
                mstore(0x44, 'ERC721: operator query for nonex')
                mstore(0x64, 'istent token')
                revert(0x00, 0x84)
            }
        }
        address owner = ownerOf(tokenId);
        bool isApprovedOrOwner = (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
        assembly {
            if iszero(isApprovedOrOwner) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x04, 0x20)
                mstore(0x24, 49)
                mstore(0x44, 'ERC721: transfer caller is not o')
                mstore(0x64, 'wner nor approved')
                revert(0x00, 0x84)
            }
        }
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, '');
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            'ERC721: transfer to non ERC721Receiver implementer'
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), 'ERC721: mint to the zero address');
        require(!_exists(tokenId), 'ERC721: token already minted');

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        assembly {
            mstore(0x00, tokenId)
            log3(0x00, 0x20, TRANSFER_SIG, 0, to)
        }
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ownerOf(tokenId) == from, 'ERC721: transfer of token that is not own');
        require(to != address(0), 'ERC721: transfer to the zero address');

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        assembly {
            mstore(0x00, tokenId)
            log3(0x00, 0x20, TRANSFER_SIG, from, to)
        }
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        address owner = ownerOf(tokenId);
        assembly {
            mstore(0x00, tokenId)
            log3(0x00, 0x20, TRANSFER_SIG, owner, to)
        }
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        bool isContract;
        assembly {
            isContract := gt(extcodesize(to), 0)
        }
        if (isContract) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert('ERC721: transfer to non ERC721Receiver implementer');
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < balanceOf(owner), 'ERC721Enumerable: owner index out of bounds');
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), 'ERC721Enumerable: global index out of bounds');
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        if (from == address(0)) {
            _allTokensIndex[tokenId] = _allTokens.length;
            _allTokens.push(tokenId);
        } else if (from != to) {
            // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
            // then delete the last slot (swap and pop).

            uint256 lastTokenIndex = balanceOf(from) - 1;
            uint256 tokenIndex = _ownedTokensIndex[tokenId];

            // When the token to delete is the last token, the swap operation is unnecessary
            if (tokenIndex != lastTokenIndex) {
                uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

                _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
                _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
            }

            // This also deletes the contents at the last position of the array
            delete _ownedTokensIndex[tokenId];
            delete _ownedTokens[from][lastTokenIndex];
        }
        if (to == address(0)) {
            // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
            // then delete the last slot (swap and pop).

            uint256 lastTokenIndex = _allTokens.length - 1;
            uint256 tokenIndex = _allTokensIndex[tokenId];

            // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
            // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
            // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
            uint256 lastTokenId = _allTokens[lastTokenIndex];

            _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

            // This also deletes the contents at the last position of the array
            delete _allTokensIndex[tokenId];
            _allTokens.pop();
        } else if (to != from) {
            uint256 length = balanceOf(to);
            _ownedTokens[to][length] = tokenId;
            _ownedTokensIndex[tokenId] = length;
        }
    }
}

contract DoomCultSocietyDAO is ERC20 {
    uint256 internal constant WEEKS_UNTIL_OBLIVION = 52;
    uint256 internal constant SECONDS_PER_WEEK = 604800;

    uint256 public sleepTimer; // can wake up once block.timestamp > sleepTimer
    uint256 public doomCounter; // number of weeks until contract is destroyed
    uint256 public timestampUntilNextEpoch; // countdown timer can decrease once block.timestamp > timestampUntilNextEpoch

    uint256 public constant NUM_STARTING_CULTISTS = 30000;

    // If currentEpochTotalSacrificed <= lastEpocTotalSacrificed when epoch ends...kaboom!
    uint256 public currentEpochTotalSacrificed;
    uint256 public lastEpochTotalSacrificed;

    mapping(address => uint256) public cultistDevotations;

    uint256 private constant IT_HAS_AWOKEN_SIG = 0x21807e0b842b099372e0a04f56a3c00df1f88de6af9d3e3ebb06d4d6fac76a8d;
    event ItHasAwoken(uint256 startNumCultists);

    uint256 private constant COUNTDOWN_SIG = 0x11d2d22584d0bb23681c07ce6959f34dfc15469ad3546712ab96e3a945c6f603;
    event Countdown(uint256 weeksRemaining);

    uint256 private constant OBLITERATE_SIG = 0x03d6576f6c77df8600e2667de4d5c1fbc7cb69b42d5eaa80345d8174d80af46b;
    event Obliterate(uint256 endNumCultists);
    bool public isAwake;
    DoomCultSociety public doomCult;

    modifier onlyAwake() {
        assembly {
            if iszero(and(sload(isAwake.slot), 1)) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x04, 0x20)
                mstore(0x24, 14)
                mstore(0x44, 'It Is Sleeping')
                revert(0x00, 0x64)
            }
        }
        _;
    }
    modifier onlyAsleep() {
        assembly {
            if and(sload(isAwake.slot), 1) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x04, 0x20)
                mstore(0x24, 12)
                mstore(0x44, 'It Has Woken')
                revert(0x00, 0x64)
            }
        }
        _;
    }

    constructor() ERC20() {
        doomCult = new DoomCultSociety();
        assembly {
            sstore(sleepTimer.slot, add(timestamp(), mul(4, SECONDS_PER_WEEK)))
        }
        // All cultists are equal... but some are more equal than others. Hon hon hon.
        _balances[address(0x24065d97424687EB9c83c87729fc1b916266F637)] = 300;
        _totalSupply = 300;
    }

    function attractCultists() public onlyAsleep {
        assembly {
            if lt(NUM_STARTING_CULTISTS, add(1, sload(_totalSupply.slot))) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x04, 0x20)
                mstore(0x24, 22)
                mstore(0x44, 'No remaining cultists!')
                revert(0x00, 0x64)
            }
            mstore(0x00, caller())
            mstore(0x20, _balances.slot)
            let balanceSlot := keccak256(0x00, 0x40)
            // _balances[msg.sender] += 3
            sstore(balanceSlot, add(sload(balanceSlot), 3))
            // _totalSupply += 3
            sstore(_totalSupply.slot, add(sload(_totalSupply.slot), 3))
            // emit Transfer(0, msg.sender, 3)
            mstore(0x00, 3)
            log3(0x00, 0x20, TRANSFER_SIG, 0, caller())
        }
    }

    function wakeUp() public onlyAsleep {
        assembly {
            if iszero(
                or(
                    gt(add(sload(_totalSupply.slot), 1), NUM_STARTING_CULTISTS),
                    gt(add(timestamp(), 1), sload(sleepTimer.slot))
                )
            ) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x04, 0x20)
                mstore(0x24, 17)
                mstore(0x44, 'Still Sleeping...')
                revert(0x00, 0x64)
            }
            sstore(isAwake.slot, or(sload(isAwake.slot), 1))
            sstore(timestampUntilNextEpoch.slot, add(timestamp(), SECONDS_PER_WEEK))
            sstore(doomCounter.slot, 1)

            // emit ItHasAwoken(_totalSupply)
            mstore(0x00, sload(_totalSupply.slot))
            log1(0x00, 0x20, IT_HAS_AWOKEN_SIG)
        }
    }

    function obliterate() internal onlyAwake {
        assembly {
            if iszero(eq(sload(doomCounter.slot), add(WEEKS_UNTIL_OBLIVION, 1))) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x04, 0x20)
                mstore(0x24, 22)
                mstore(0x44, 'Too Soon To Obliterate')
                revert(0x00, 0x64)
            }

            // emit Obliterate(_totalSupply)
            mstore(0x00, sload(_totalSupply.slot))
            log1(0x00, 0x20, OBLITERATE_SIG)
            selfdestruct(0x00) // so long and thanks for all the fish
        }
    }

    function sacrifice() public onlyAwake {
        uint256 remainingCultists;
        assembly {
            mstore(0x00, caller())
            mstore(0x20, _balances.slot)
            let slot := keccak256(0x00, 0x40)
            let userBal := sload(slot)
            if iszero(userBal) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x04, 0x20)
                mstore(0x24, 21)
                mstore(0x44, 'Insufficient Cultists')
                revert(0x00, 0x64)
            }
            sstore(slot, sub(userBal, 1))
            sstore(currentEpochTotalSacrificed.slot, add(sload(currentEpochTotalSacrificed.slot), 1))
            remainingCultists := sub(sload(_totalSupply.slot), 1)
            sstore(_totalSupply.slot, remainingCultists)
        }
        doomCult.mint(doomCounter, remainingCultists, msg.sender);
        assembly {
            // emit Transfer(msg.sender, 0, 1)
            mstore(0x00, 1)
            log3(0x00, 0x20, TRANSFER_SIG, caller(), 0)
        }
    }

    function worship() public payable onlyAwake {
        assembly {
            if gt(sload(timestampUntilNextEpoch.slot), add(timestamp(), 1)) {
                mstore(0x00, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(0x04, 0x20)
                mstore(0x24, 8)
                mstore(0x44, 'Too Soon')
                revert(0x00, 0x64)
            }
        }

        if (lastEpochTotalSacrificed >= currentEpochTotalSacrificed) {
            assembly {
                // emit Obliterate(_totalSupply)
                mstore(0x00, sload(_totalSupply.slot))
                log1(0x00, 0x20, OBLITERATE_SIG)
                selfdestruct(0x00) // womp womp
            }
        }
        assembly {
            sstore(lastEpochTotalSacrificed.slot, sload(currentEpochTotalSacrificed.slot))
            sstore(currentEpochTotalSacrificed.slot, 0)
            sstore(timestampUntilNextEpoch.slot, add(timestamp(), SECONDS_PER_WEEK))
            sstore(doomCounter.slot, add(sload(doomCounter.slot), 1))
        }
        if (doomCounter == (WEEKS_UNTIL_OBLIVION + 1)) {
            obliterate();
        }
        // emit Countdown(doomCounter)
        assembly {
            mstore(0x00, sload(doomCounter.slot))
            log1(0x00, 0x20, COUNTDOWN_SIG)
        }
    }
}

contract DoomCultSociety is ERC721Enumerable {
    address doomCultSocietyDAO;
    uint256 numberOfDoomCultists;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() ERC721Enumerable() {
        doomCultSocietyDAO = msg.sender;
        _status = _NOT_ENTERED;
    }

    function mint(
        uint256 countdown,
        uint256 remainingCultists,
        address owner
    ) public {
        require(_status != _ENTERED, 'ReentrancyGuard: reentrant call');
        _status = _ENTERED;
        uint256 tokenId = (remainingCultists * 100000000) + (countdown * 1000000) + numberOfDoomCultists;
        require(msg.sender == doomCultSocietyDAO, 'Only the Doom Cult Society DAO can mint');
        _mint(owner, tokenId);
        numberOfDoomCultists += 1;
        _status = _NOT_ENTERED;
    }

    function getImgData(uint256 tokenId) internal pure returns (string memory res) {
        assembly {
            // Token information
            // tokenId % 1,000,000 = index of token (i.e. how many were minted before this token)
            // (tokenId / 1,000,000) % 100 = week in which sacrificed occured (from game start)
            // (tokenId / 100,000,000) = number of cultists remaining after sacrifice
            let countdown := mod(div(tokenId, 1000000), 100)
            mstore(0x00, tokenId)
            mstore(0x20, 5148293888310004) // some salt for your token
            let seed := keccak256(0x00, 0x40)
            let p := add(mload(0x40), 0x400)
            res := sub(p, 0x20)
            mstore(add(p, 0x00), 0x3c73766720786d6c6e733d27687474703a2f2f7777772e77332e6f72672f3230)
            mstore(add(p, 0x20), 0x30302f7376672720786d6c6e733a786c696e6b3d27687474703a2f2f7777772e)
            mstore(add(p, 0x40), 0x77332e6f72672f313939392f786c696e6b272077696474683d27373030272068)
            mstore(add(p, 0x60), 0x65696768743d27383030273e3c7374796c653e2e68656176792c2e7375706572)
            mstore(add(p, 0x80), 0x68656176797b666f6e743a37303020333070782073616e732d73657269663b66)
            mstore(add(p, 0xa0), 0x696c6c3a236666667d3c2f7374796c653e3c70617468207374796c653d276669)
            mstore(add(p, 0xc0), 0x6c6c3a233030302720643d274d30203068383030763130303048307a272f3e3c)
            mstore(add(p, 0xe0), 0x67207472616e73666f726d3d276d6174726978282e3120302030202d2e31202d)
            mstore(add(p, 0x100), 0x3335302036353029273e3c646566733e3c672069643d27666c6f77657241273e)
            mstore(add(p, 0x120), 0x3c636972636c652063783d272d3230272063793d273231302720723d27313030)
            mstore(add(p, 0x140), 0x272f3e3c75736520786c696e6b3a687265663d2723706574616c33272f3e3c75)
            mstore(add(p, 0x160), 0x736520786c696e6b3a687265663d2723706574616c3327207472616e73666f72)
            mstore(add(p, 0x180), 0x6d3d27726f746174652834352033302e3731203236372e323829272f3e3c7573)
            mstore(add(p, 0x1a0), 0x6520786c696e6b3a687265663d2723706574616c3327207472616e73666f726d)
            mstore(add(p, 0x1c0), 0x3d27726f74617465283930202d32302032343029272f3e3c2f673e3c67206964)
            mstore(add(p, 0x1e0), 0x3d27666c6f77657242273e3c75736520786c696e6b3a687265663d2723706574)
            mstore(add(p, 0x200), 0x616c34272f3e3c75736520786c696e6b3a687265663d2723706574616c342720)
            mstore(add(p, 0x220), 0x7472616e73666f726d3d27726f74617465283435202d31392e36343520323138)
            mstore(add(p, 0x240), 0x2e31333729272f3e3c75736520786c696e6b3a687265663d2723706574616c34)
            mstore(add(p, 0x260), 0x27207472616e73666f726d3d27726f74617465283930202d3330203233302927)
            mstore(add(p, 0x280), 0x2f3e3c75736520786c696e6b3a687265663d2723706574616c3427207472616e)
            mstore(add(p, 0x2a0), 0x73666f726d3d27726f74617465282d3438202d33372e333032203231382e3435)
            mstore(add(p, 0x2c0), 0x3329272f3e3c2f673e3c672069643d276465636f72617469766531273e3c7573)
            mstore(add(p, 0x2e0), 0x6520786c696e6b3a687265663d27236227207374796c653d2766696c6c3a2366)
            mstore(add(p, 0x300), 0x3537393134272f3e3c75736520786c696e6b3a687265663d2723746561722720)
            mstore(add(p, 0x320), 0x783d272d3230303027207472616e73666f726d3d276d6174726978282e343434)
            mstore(add(p, 0x340), 0x363320312e32323136202d312e3033333636202e333736323220373437312e36)
            mstore(add(p, 0x360), 0x3239202d323437302e3539322927207374796c653d2766696c6c3a2333313262)
            mstore(add(p, 0x380), 0x3564272f3e3c2f673e3c672069643d276465636f726174697665322720747261)
            mstore(add(p, 0x3a0), 0x6e73666f726d3d277472616e736c6174652835313530203431303029273e3c75)
            mstore(add(p, 0x3c0), 0x736520786c696e6b3a687265663d2723666c6f7765724127207374796c653d27)
            mstore(add(p, 0x3e0), 0x66696c6c3a23656431633234272f3e3c75736520786c696e6b3a687265663d27)
            mstore(add(p, 0x400), 0x23666c6f7765724227207374796c653d2766696c6c3a23386331623835272f3e)
            mstore(add(p, 0x420), 0x3c2f673e3c672069643d276465636f72617469766533273e3c75736520786c69)
            mstore(add(p, 0x440), 0x6e6b3a687265663d272374656172332720783d273936302720793d272d343430)
            mstore(add(p, 0x460), 0x3027207472616e73666f726d3d277363616c65282e39202d2e37292720737479)
            mstore(add(p, 0x480), 0x6c653d2766696c6c3a23303939346433272f3e3c75736520786c696e6b3a6872)
            mstore(add(p, 0x4a0), 0x65663d2723746561723327207472616e73666f726d3d277363616c65282e3720)
            mstore(add(p, 0x4c0), 0x2d2e372920726f746174652834302031343238332e34343120353830312e3030)
            mstore(add(p, 0x4e0), 0x392927207374796c653d2766696c6c3a23656431633234272f3e3c2f673e3c67)
            mstore(add(p, 0x500), 0x2069643d27666c6f77657243273e3c75736520786c696e6b3a687265663d2723)
            mstore(add(p, 0x520), 0x666c6f7765724127207374796c653d2766696c6c3a23303939346433272f3e3c)
            mstore(add(p, 0x540), 0x75736520786c696e6b3a687265663d2723666c6f7765724227207374796c653d)
            mstore(add(p, 0x560), 0x2766696c6c3a23386331623835272f3e3c2f673e3c672069643d276465636f72)
            mstore(add(p, 0x580), 0x61746976653427207472616e73666f726d3d27726f7461746528313235203334)
            mstore(add(p, 0x5a0), 0x39352e39343320313934362e39373229207363616c65282e3629273e3c757365)
            mstore(add(p, 0x5c0), 0x20786c696e6b3a687265663d2723666c6f7765724127207374796c653d276669)
            mstore(add(p, 0x5e0), 0x6c6c3a23663537393134272f3e3c75736520786c696e6b3a687265663d272366)
            mstore(add(p, 0x600), 0x6c6f7765724227207374796c653d2766696c6c3a23386331623835272f3e3c2f)
            mstore(add(p, 0x620), 0x673e3c672069643d276465636f72617469766535273e3c75736520786c696e6b)
            mstore(add(p, 0x640), 0x3a687265663d2723746561722720783d272d323130302720793d273136353027)
            mstore(add(p, 0x660), 0x207472616e73666f726d3d276d6174726978282d312e3430393534202e353133)
            mstore(add(p, 0x680), 0x3033202e30363834202d312e34303833332031323037302e3539322036303731)
            mstore(add(p, 0x6a0), 0x2e3632392927207374796c653d2766696c6c3a23666666272f3e3c636972636c)
            mstore(add(p, 0x6c0), 0x652063783d2736343730272063793d27313738302720723d2731333027207374)
            mstore(add(p, 0x6e0), 0x796c653d2766696c6c3a23303939346433272f3e3c636972636c652063783d27)
            mstore(add(p, 0x700), 0x35373730272063793d27313335302720723d27373027207374796c653d276669)
            mstore(add(p, 0x720), 0x6c6c3a23656431633234272f3e3c636972636c652063783d2735383230272063)
            mstore(add(p, 0x740), 0x793d27313135302720723d27373027207374796c653d2766696c6c3a23656431)
            mstore(add(p, 0x760), 0x633234272f3e3c636972636c652063783d2735373230272063793d2731353530)
            mstore(add(p, 0x780), 0x2720723d27373027207374796c653d2766696c6c3a23656431633234272f3e3c)
            mstore(add(p, 0x7a0), 0x636972636c652063783d2736313930272063793d27313730302720723d273830)
            mstore(add(p, 0x7c0), 0x27207374796c653d2766696c6c3a23656431633234272f3e3c2f673e3c672069)
            mstore(add(p, 0x7e0), 0x643d276465636f72617469766536273e3c636972636c652063783d2736303030)
            mstore(add(p, 0x800), 0x272063793d27313635302720723d27383027207374796c653d2766696c6c3a23)
            mstore(add(p, 0x820), 0x303939346433272f3e3c636972636c652063783d2736333730272063793d2732)
            mstore(add(p, 0x840), 0x30302720723d27383027207374796c653d2766696c6c3a23663537393134272f)
            mstore(add(p, 0x860), 0x3e3c7061746820643d274d363330302031373130632d372d31332d362d32362d)
            mstore(add(p, 0x880), 0x342d343173392d32362031372d333763362d31312032322d31372034312d3234)
            mstore(add(p, 0x8a0), 0x2031372d34203434203920373920343120333520333320363320313331203835)
            mstore(add(p, 0x8c0), 0x203239392d39322d3132342d3135332d3139342d3138332d3230372d342d322d)
            mstore(add(p, 0x8e0), 0x392d342d31332d362d31302d342d31372d31332d32322d32346d2d3437302d31)
            mstore(add(p, 0x900), 0x3631632d323620322d35302d362d37322d32362d31392d31372d33332d33392d)
            mstore(add(p, 0x920), 0x33392d36352d342d31332032302d3136342037322d3435322035302d32383620)
            mstore(add(p, 0x940), 0x3138312d353330203339332d3733312d323031203432312d323932203730392d)
            mstore(add(p, 0x960), 0x323737203836302031352031353020323020323437203133203238342d362033)
            mstore(add(p, 0x980), 0x372d31372036382d32382039302d31352032342d33372033392d363120343127)
            mstore(add(p, 0x9a0), 0x207374796c653d2766696c6c3a23656431633234272f3e3c2f673e3c67206964)
            mstore(add(p, 0x9c0), 0x3d276465636f72617469766537273e3c75736520786c696e6b3a687265663d27)
            mstore(add(p, 0x9e0), 0x2374656172332720783d273936302720793d272d38343027207472616e73666f)
            mstore(add(p, 0xa00), 0x726d3d277363616c65282e3920312e362927207374796c653d2766696c6c3a23)
            mstore(add(p, 0xa20), 0x303939346433272f3e3c75736520786c696e6b3a687265663d27237465617232)
            mstore(add(p, 0xa40), 0x27207472616e73666f726d3d27726f74617465282d3530203633343020343630)
            mstore(add(p, 0xa60), 0x302927207374796c653d2766696c6c3a23666666272f3e3c75736520786c696e)
            mstore(add(p, 0xa80), 0x6b3a687265663d272374656172332720783d273430302720793d272d35333027)
            mstore(add(p, 0xaa0), 0x207472616e73666f726d3d277363616c65282e3920312e332920726f74617465)
            mstore(add(p, 0xac0), 0x283330203637343020343330302927207374796c653d2766696c6c3a23656431)
            mstore(add(p, 0xae0), 0x633234272f3e3c2f673e3c672069643d276465636f7261746976653827207472)
            mstore(add(p, 0xb00), 0x616e73666f726d3d277472616e736c6174652837313030203531303029273e3c)
            mstore(add(p, 0xb20), 0x75736520786c696e6b3a687265663d2723706574616c3327207472616e73666f)
            mstore(add(p, 0xb40), 0x726d3d27726f74617465282d313030202d3135382e3536342036342e38383729)
            mstore(add(p, 0xb60), 0x207363616c65282e362927207374796c653d2766696c6c3a2365643163323427)
            mstore(add(p, 0xb80), 0x2f3e3c75736520786c696e6b3a687265663d2723666c6f776572432720747261)
            mstore(add(p, 0xba0), 0x6e73666f726d3d27726f746174652831323529207363616c65282e3629272f3e)
            mstore(add(p, 0xbc0), 0x3c75736520786c696e6b3a687265663d2723666c6f7765724327207472616e73)
            mstore(add(p, 0xbe0), 0x666f726d3d277363616c65282d2e36202e362920726f74617465282d3535202d)
            mstore(add(p, 0xc00), 0x3237322e3134202d3134312e36363729272f3e3c2f673e3c672069643d276227)
            mstore(add(p, 0xc20), 0x3e3c636972636c652063783d2735363330272063793d27343036302720723d27)
            mstore(add(p, 0xc40), 0x313430272f3e3c636972636c652063783d2735343030272063793d2733383530)
            mstore(add(p, 0xc60), 0x2720723d27313130272f3e3c636972636c652063783d2735323730272063793d)
            mstore(add(p, 0xc80), 0x27333630302720723d273930272f3e3c636972636c652063783d273531383027)
            mstore(add(p, 0xca0), 0x2063793d27333335302720723d273730272f3e3c636972636c652063783d2735)
            mstore(add(p, 0xcc0), 0x313530272063793d27333135302720723d273630272f3e3c2f673e3c67206964)
            mstore(add(p, 0xce0), 0x3d27717561727465725f657965273e3c636972636c652063783d273638343027)
            mstore(add(p, 0xd00), 0x2063793d27333036302720723d2731363527207374796c653d2766696c6c3a23)
            mstore(add(p, 0xd20), 0x656431333434272f3e3c636972636c652063783d2736373730272063793d2733)
            mstore(add(p, 0xd40), 0x3333352720723d2731363527207374796c653d2766696c6c3a23656431333434)
            mstore(add(p, 0xd60), 0x272f3e3c636972636c652063783d2736363430272063793d2733353335272072)
            mstore(add(p, 0xd80), 0x3d2731363527207374796c653d2766696c6c3a23656431333434272f3e3c6369)
            mstore(add(p, 0xda0), 0x72636c652063783d2736333935272063793d27333639302720723d2731363527)
            mstore(add(p, 0xdc0), 0x207374796c653d2766696c6c3a23656431333434272f3e3c636972636c652063)
            mstore(add(p, 0xde0), 0x783d2736383430272063793d27333036302720723d27383027207374796c653d)
            mstore(add(p, 0xe00), 0x2766696c6c3a23303939346433272f3e3c636972636c652063783d2736373730)
            mstore(add(p, 0xe20), 0x272063793d27333333352720723d27383027207374796c653d2766696c6c3a23)
            mstore(add(p, 0xe40), 0x303939346433272f3e3c636972636c652063783d2736363430272063793d2733)
            mstore(add(p, 0xe60), 0x3533352720723d27383027207374796c653d2766696c6c3a2330393934643327)
            mstore(add(p, 0xe80), 0x2f3e3c636972636c652063783d2736333935272063793d27333639302720723d)
            mstore(add(p, 0xea0), 0x27383027207374796c653d2766696c6c3a23303939346433272f3e3c2f673e3c)
            mstore(add(p, 0xec0), 0x672069643d2765796531273e3c75736520786c696e6b3a687265663d27237175)
            mstore(add(p, 0xee0), 0x61727465725f657965272f3e3c75736520786c696e6b3a687265663d27237175)
            mstore(add(p, 0xf00), 0x61727465725f65796527207472616e73666f726d3d27726f7461746528313830)
            mstore(add(p, 0xf20), 0x2036313530203330363029272f3e3c75736520786c696e6b3a687265663d2723)
            mstore(add(p, 0xf40), 0x717561727465725f65796527207472616e73666f726d3d27726f746174652832)
            mstore(add(p, 0xf60), 0x37302036313530203330363029272f3e3c75736520786c696e6b3a687265663d)
            mstore(add(p, 0xf80), 0x2723717561727465725f65796527207472616e73666f726d3d27726f74617465)
            mstore(add(p, 0xfa0), 0x2839302036313530203330363029272f3e3c2f673e3c7061746820643d274d37)
            mstore(add(p, 0xfc0), 0x3530372035353832632d3136382033332d3334302035302d3531372035322d31)
            mstore(add(p, 0xfe0), 0x37372d322d3334392d32302d3531372d35322d3334352d36382d3635392d3234)
            mstore(add(p, 0x1000), 0x342d3934312d3533302d3238342d3238362d3436392d3535362d3535362d3831)
            mstore(add(p, 0x1020), 0x342d32302d35372d33352d3131362d35302d3137352d33332d3133382d34382d)
            mstore(add(p, 0x1040), 0x3238342d34362d34333620302d3435322037342d383033203232302d31303536)
            mstore(add(p, 0x1060), 0x2039382d313638203133332d333334203130322d3439352d33302d3135392032)
            mstore(add(p, 0x1080), 0x302d333038203134382d3434312036382d3638203132322d313237203136362d)
            mstore(add(p, 0x10a0), 0x3137372034312d34362037342d38352039362d3131362034342d323535203132)
            mstore(add(p, 0x10c0), 0x302d353236203232392d383037203130392d323832203330312d343433203537)
            mstore(add(p, 0x10e0), 0x362d3438392033392d362037362d3131203131312d3138203330382d33372036)
            mstore(add(p, 0x1100), 0x31332d3337203932312030203335203720373220313120313133203137203237)
            mstore(add(p, 0x1120), 0x3320343620343635203230372035373420343839203130392032383120313835)
            mstore(add(p, 0x1140), 0x2035353220323239203830372034362036332031333320313539203236322032)
            mstore(add(p, 0x1160), 0x393273313739203238322031343820343431632d333020313631203420333237)
            mstore(add(p, 0x1180), 0x2031303320343935203134362032353320323230203630352032323320313035)
            mstore(add(p, 0x11a0), 0x362d32203231382d3335203432312d3938203631312d3839203235382d323735)
            mstore(add(p, 0x11c0), 0x203532382d353536203831342d323833203238362d353938203436332d393431)
            mstore(add(p, 0x11e0), 0x2035333027207374796c653d2766696c6c3a23666363613037272069643d2766)
            mstore(add(p, 0x1200), 0x616365272f3e3c7061746820643d274d373234332031343239632d322032342d)
            mstore(add(p, 0x1220), 0x31302034332d32362036312d31352031372d33342032362d3534203236682d36)
            mstore(add(p, 0x1240), 0x37632d323120302d34312d392d35372d32362d31352d31372d32342d33372d32)
            mstore(add(p, 0x1260), 0x322d3631762d323630632d322d323420362d34342032322d36312031352d3137)
            mstore(add(p, 0x1280), 0x2033352d32362035372d32366836386332302030203339203920353420323673)
            mstore(add(p, 0x12a0), 0x3234203337203236203631763236306d2d392d343837632d322032322d392034)
            mstore(add(p, 0x12c0), 0x312d32342035372d31352031372d33332032362d3532203236682d3635632d32)
            mstore(add(p, 0x12e0), 0x3020302d33372d392d35322d32362d31352d31352d32322d33352d32322d3537)
            mstore(add(p, 0x1300), 0x5636393563302d323220362d34312032322d35372031352d31352033332d3234)
            mstore(add(p, 0x1320), 0x2035322d32346836356332302030203337203820353220323420313520313520)
            mstore(add(p, 0x1340), 0x3232203335203234203537763234366d3832203836632d31352d32302d32322d)
            mstore(add(p, 0x1360), 0x33392d32322d36336c2e30312d32363063302d323420362d34312032322d3537)
            mstore(add(p, 0x1380), 0x2031352d31332033302d31372035302d31336c35392031336332302034203335)
            mstore(add(p, 0x13a0), 0x20313520353020333520362031312031332032342031352e3334203337203220)
            mstore(add(p, 0x13c0), 0x39203420313720342032347632343263302032342d362034312d32302035372d)
            mstore(add(p, 0x13e0), 0x31352031352d33302032322d35302031396d3236332e3635203630682d353963)
            mstore(add(p, 0x1400), 0x2d323020302d33372d392d35342d32342d31352d31352d32322d33332d32322d)
            mstore(add(p, 0x1420), 0x35325638313663302d313720362d33352032322d34382031352d31312033312d)
            mstore(add(p, 0x1440), 0x31352034362d313368396c353820313563313720342033322031332034362032)
            mstore(add(p, 0x1460), 0x382031332031372032302033352032302035327632303463302032302d362033)
            mstore(add(p, 0x1480), 0x352d32302034382d31332031332d32382032302d34362032306d323934203337)
            mstore(add(p, 0x14a0), 0x33632d31312031312d32342031372d3339203137682d3530632d313720302d33)
            mstore(add(p, 0x14c0), 0x332d362d34382d32302d31332d31332d32302d32382d32302d3438762d323031)
            mstore(add(p, 0x14e0), 0x63302d313520362d32382032302d33392031312d392032342d31332033392d31)
            mstore(add(p, 0x1500), 0x3368396c35302031336331352032203238203131203339203236733137203331)
            mstore(add(p, 0x1520), 0x2031372034367631373763302031352d362033312d31372034316d2d3438302d)
            mstore(add(p, 0x1540), 0x363563302032322d372034312d32302035372d31352031382d33302032362d34)
            mstore(add(p, 0x1560), 0x38203236682d3538632d323020302d33372d392d35322d3236732d32322d3337)
            mstore(add(p, 0x1580), 0x2d32322d3631762d32363063302d323420362d34332032322d35392031352d31)
            mstore(add(p, 0x15a0), 0x352033332d32302035322d31376c353920366331372032203333203133203438)
            mstore(add(p, 0x15c0), 0x203333203133203137203230203337203230203539763234326d3338312d3236)
            mstore(add(p, 0x15e0), 0x32632d31372d322d33332d392d34382d32342d31332d31352d32302d33302d31)
            mstore(add(p, 0x1600), 0x372d353056383932632d322d313520342d32382031372d33377332362d313320)
            mstore(add(p, 0x1620), 0x34312d31316332203220342032203620326c3532203137633135203720323820)
            mstore(add(p, 0x1640), 0x3135203339203331203131203135203137203333203137203438763137386330)
            mstore(add(p, 0x1660), 0x2031352d362032382d3137203339732d32342031352d33392031336c2d35322d)
            mstore(add(p, 0x1680), 0x342e344d373538342031343838632d31352d31352d32322d33332d32322d3532)
            mstore(add(p, 0x16a0), 0x762d32323963302d323020362d33352032322d34382031332d31312032382d31)
            mstore(add(p, 0x16c0), 0x352034342d31336831316c353720313563313720342033332031332034382032)
            mstore(add(p, 0x16e0), 0x382031332031372032302033352032302035327632303363302031392d362033)
            mstore(add(p, 0x1700), 0x352d32302034382d31352031332d33302032302d3438203230682d3537632d32)
            mstore(add(p, 0x1720), 0x3020302d33392d392d35352d3234272069643d277465657468272f3e3c706174)
            mstore(add(p, 0x1740), 0x6820643d274d30203063342d35342d312d3131322d31372d3137372d392e372d)
            mstore(add(p, 0x1760), 0x34302d31382d37332d33312d31303320372d33322032312d36312033362d3833)
            mstore(add(p, 0x1780), 0x2032382d34382035332d37312037382d37332032322034203339203331203534)
            mstore(add(p, 0x17a0), 0x2038312038203334203132203735203131203131352d31392032322d33362034)
            mstore(add(p, 0x17c0), 0x372d35312037344334332d3130372031342d353120302030272069643d277065)
            mstore(add(p, 0x17e0), 0x74616c33272f3e3c7061746820643d274d3235302d3334306334312d33362037)
            mstore(add(p, 0x1800), 0x352d34382039362d34302032312031322032352034362031342039352d352033)
            mstore(add(p, 0x1820), 0x302d31352035392d32382038382d382031372d31342033372d32352035362d38)
            mstore(add(p, 0x1840), 0x2031372d32302033342d33302035342d34342036382d3931203132342d313430)
            mstore(add(p, 0x1860), 0x203136332d32302031362d34302032382d35352033362d313520342d32372037)
            mstore(add(p, 0x1880), 0x2d333720346c2d322d32632d3420302d372d352d392d372d372d392d31302d32)
            mstore(add(p, 0x18a0), 0x312d31322d333820302d313420312d333020362d35322031322d35382034302d)
            mstore(add(p, 0x18c0), 0x3132342038332d31393420352d372031322d31332031372d32302031302d3139)
            mstore(add(p, 0x18e0), 0x2032332d34302033392d35372032382d33332035362d36332038352d38362720)
            mstore(add(p, 0x1900), 0x69643d27706574616c34272f3e3c7061746820643d274d343430302034343030)
            mstore(add(p, 0x1920), 0x63342d35342d312d3131322d31372d3137372d392d34302d31382d37332d3331)
            mstore(add(p, 0x1940), 0x2d31303320372d33322032312d36312033362d38332032382d34382035332d37)
            mstore(add(p, 0x1960), 0x312037382d373320323220342033392033312035342038312038203334203132)
            mstore(add(p, 0x1980), 0x203735203131203131352d31392032322d33362034372d35312037342d333720)
            mstore(add(p, 0x19a0), 0x35392d3636203131352d38302031363627207374796c653d2766696c6c3a2365)
            mstore(add(p, 0x19c0), 0x6431633234272069643d27706574616c31272f3e3c7061746820643d274d3436)
            mstore(add(p, 0x19e0), 0x353020343036306334312d33362037352d34382039362d343020323120313220)
            mstore(add(p, 0x1a00), 0x32352034362031342039352d352033302d31352035392d32382038382d382031)
            mstore(add(p, 0x1a20), 0x372d31342033372d32352035362d382031372d32302033342d33302035342d34)
            mstore(add(p, 0x1a40), 0x342036382d3931203132342d313430203136332d32302031362d34302032382d)
            mstore(add(p, 0x1a60), 0x35352033362d313520342d323720372d333720346c2d322d32632d3420302d37)
            mstore(add(p, 0x1a80), 0x2d352d392d372d372d392d31302d32312d31322d333820302d313420312d3330)
            mstore(add(p, 0x1aa0), 0x20362d35322031322d35382034302d3132342038332d31393420352d37203132)
            mstore(add(p, 0x1ac0), 0x2d31332031372d32302031302d31392032332d34302033392d35372032382d33)
            mstore(add(p, 0x1ae0), 0x332035362d36332038352d383627207374796c653d2766696c6c3a2338633162)
            mstore(add(p, 0x1b00), 0x3835272069643d27706574616c32272f3e3c7061746820643d274d3539363020)
            mstore(add(p, 0x1b20), 0x33373230632d333320392d37362032302d3132372033332d39342032382d3135)
            mstore(add(p, 0x1b40), 0x302033352d3136362032342d31372d31312d32382d36352d33332d3135392d34)
            mstore(add(p, 0x1b60), 0x2d35392d392d3130392d31312d3134382d33332d31312d37322d32362d313232)
            mstore(add(p, 0x1b80), 0x2d34362d39322d33332d3134322d36312d3135302d38312d372d31372031372d)
            mstore(add(p, 0x1ba0), 0x36382036382d3134382033332d35302035392d39322037382d3132342d32302d)
            mstore(add(p, 0x1bc0), 0x32382d34342d36352d37322d3131312d35352d38312d37382d3133312d37322d)
            mstore(add(p, 0x1be0), 0x31353020342d32302035302d3436203134302d37382035352d3232203130302d)
            mstore(add(p, 0x1c00), 0x3431203133382d353720322d323620342d353920372d3936762d333563342d39)
            mstore(add(p, 0x1c20), 0x382031352d3135332033312d3136342031352d31312036382d36203136312031)
            mstore(add(p, 0x1c40), 0x3720353720313520313035203236203134322033352032322d32362035302d36)
            mstore(add(p, 0x1c60), 0x312038332d3130332036312d3736203130322d313133203132322d3131362032)
            mstore(add(p, 0x1c80), 0x3020302035392033372031323020313039203337203436203638203835203934)
            mstore(add(p, 0x1ca0), 0x203131332033332d372037362d3230203132392d33352039342d323420313438)
            mstore(add(p, 0x1cc0), 0x2d3333203136362d323220313520313120323620363520333320313539203020)
            mstore(add(p, 0x1ce0), 0x313520302032382032203339203220343120342e333820373920362031303720)
            mstore(add(p, 0x1d00), 0x3333203133203734203238203132342034382039322033352031343020363120)
            mstore(add(p, 0x1d20), 0x31343620373920362032302d31372036382d3638203134382d33332035302d35)
            mstore(add(p, 0x1d40), 0x372039322d373620313234203138203330203431203638203732203131312035)
            mstore(add(p, 0x1d60), 0x322e343320383120373620313331203732203135302d362032302d3532203438)
            mstore(add(p, 0x1d80), 0x2d3134322038312d35342032322d3130302033392d3133352035342d32203335)
            mstore(add(p, 0x1da0), 0x2d342037382d36203133332d342039382d3135203135332d3330203136342d31)
            mstore(add(p, 0x1dc0), 0x352031332d373020362d3136312d31372d35392d31352d3130372d32362d3134)
            mstore(add(p, 0x1de0), 0x342d33352d32322032362d35302036312d3833203130332d36312037362d3130)
            mstore(add(p, 0x1e00), 0x30203131362d31323020313136732d36312d33372d3132302d313131632d3337)
            mstore(add(p, 0x1e20), 0x2d34362d37302d38332d39362d313131272069643d2765796532272f3e3c7061)
            mstore(add(p, 0x1e40), 0x746820643d274d363530302034313030632d32352e323420382e33392d35332e)
            mstore(add(p, 0x1e60), 0x323820352e35392d37382e352d322e38332d33302e38342d382e342d35332e32)
            mstore(add(p, 0x1e80), 0x382d32382e30342d36312e36382d35332e32362d31312e32322d32352e32332d)
            mstore(add(p, 0x1ea0), 0x382e34322d35332e323620352e35382d37382e35312031312e32332d32322e34)
            mstore(add(p, 0x1ec0), 0x332033302e38342d33392e32362035362e312d35332e32362031312e32312d35)
            mstore(add(p, 0x1ee0), 0x2e362032352e32322d31312e32322033392e32362d31362e38342038362e3839)
            mstore(add(p, 0x1f00), 0x2d33302e3833203138322e32342d38392e37203238382e37372d3137362e3633)
            mstore(add(p, 0x1f20), 0x2d35332e3237203231332e30392d3132302e3535203333362e34362d3230342e)
            mstore(add(p, 0x1f40), 0x3637203336372e332d31342e303220352e36312d33302e38342031312e322d34)
            mstore(add(p, 0x1f60), 0x342e38362031342e3033272069643d2774656172272f3e3c7061746820643d27)
            mstore(add(p, 0x1f80), 0x4d3537363920343837366332373420323120343135203835203639322d313237)
            mstore(add(p, 0x1fa0), 0x2d313135203135392d323431203236362d333739203332362d38392033362d32)
            mstore(add(p, 0x1fc0), 0x31382038302d3331362036332d37302d31332d3131372d33372d3133362d3635)
            mstore(add(p, 0x1fe0), 0x2d32352d33332d33342d36382d32362d3130337332392d36322036362d383063)
            mstore(add(p, 0x2000), 0x32382d31362036322d3232203130302d3134272069643d277465617232272f3e)
            mstore(add(p, 0x2020), 0x3c7061746820643d274d363734302034333030632d31362e38312d32322e3432)
            mstore(add(p, 0x2040), 0x2d32352e32332d34372e36372d32382e30332d37382e3531762d35302e343663)
            mstore(add(p, 0x2060), 0x2d322e38312d39382e31332033332e36342d3232392e3932203130392e33332d)
            mstore(add(p, 0x2080), 0x3430302e39342036312e3638203136382e32312039322e3532203330322e3831)
            mstore(add(p, 0x20a0), 0x2039322e3532203430302e39347635302e3436632d322e37382033302e38342d)
            mstore(add(p, 0x20c0), 0x31342035362e30392d33302e38342037382e35312d31392e36312032352e3233)
            mstore(add(p, 0x20e0), 0x2d34342e38342033392e32362d37302e30382033392e32362d32382e30332030)
            mstore(add(p, 0x2100), 0x2d35332e32372d31342e30332d37322e392d33392e3236272069643d27746561)
            mstore(add(p, 0x2120), 0x7233272f3e3c672069643d2768616c66273e3c75736520786c696e6b3a687265)
            mstore(add(p, 0x2140), 0x663d27236227207472616e73666f726d3d27726f746174652831333020363133)
            mstore(add(p, 0x2160), 0x3020333130302927207374796c653d2766696c6c3a23396164646630272f3e3c)
            mstore(add(p, 0x2180), 0x636972636c652063783d2736363635272063793d27343434302720723d273830)
            mstore(add(p, 0x21a0), 0x27207374796c653d2766696c6c3a23303939346433272f3e3c636972636c6520)
            mstore(add(p, 0x21c0), 0x63783d2736333730272063793d27343531302720723d27383027207374796c65)
            mstore(add(p, 0x21e0), 0x3d2766696c6c3a23303939346433272f3e3c636972636c652063783d27363438)
            mstore(add(p, 0x2200), 0x30272063793d27343336302720723d27363027207374796c653d2766696c6c3a)
            mstore(add(p, 0x2220), 0x23303939346433272f3e3c75736520786c696e6b3a687265663d272374656172)
            mstore(add(p, 0x2240), 0x3327207374796c653d2766696c6c3a23303939346433272f3e3c636972636c65)
            mstore(add(p, 0x2260), 0x2063783d2737303030272063793d27333930302720723d27353027207374796c)
            mstore(add(p, 0x2280), 0x653d2766696c6c3a23303939346433272f3e3c75736520786c696e6b3a687265)
            mstore(add(p, 0x22a0), 0x663d2723746561722720783d273131302720793d27353027207472616e73666f)
            mstore(add(p, 0x22c0), 0x726d3d27726f74617465282d3230203635303020343130302927207374796c65)
            mstore(add(p, 0x22e0), 0x3d2766696c6c3a23656431633234272f3e3c75736520786c696e6b3a68726566)
            mstore(add(p, 0x2300), 0x3d2723746561723227207374796c653d2766696c6c3a23656431633234272f3e)
            mstore(add(p, 0x2320), 0x3c636972636c652063783d2735333530272063793d27323535302720723d2738)
            mstore(add(p, 0x2340), 0x3027207374796c653d2766696c6c3a23656431633234272f3e3c636972636c65)
            mstore(add(p, 0x2360), 0x2063783d2735343230272063793d27323238302720723d273133302720737479)
            mstore(add(p, 0x2380), 0x6c653d2766696c6c3a23656431633234272f3e3c636972636c652063783d2735)
            mstore(add(p, 0x23a0), 0x393530272063793d27343530302720723d27353027207374796c653d2766696c)
            mstore(add(p, 0x23c0), 0x6c3a23656431633234272f3e3c7061746820643d274d3538343420343539332e)
            mstore(add(p, 0x23e0), 0x33316333362e34342033362e34352038312e33312035332e3237203133342e35)
            mstore(add(p, 0x2400), 0x372035362e30382035332e3320322e38312038392e37332d31362e3832203130)
            mstore(add(p, 0x2420), 0x392e33362d35332e32382031392e36332d33362e34342031342e30322d37322e)
            mstore(add(p, 0x2440), 0x392d31362e38332d3130332e37342d33302e38332d33302e38342d33392e3233)
            mstore(add(p, 0x2460), 0x2d36312e36382d32352e32322d38392e37312031312e32312d32352e32342034)
            mstore(add(p, 0x2480), 0x322e30352d33332e36352039322e35322d31392e36332035302e34362031342e)
            mstore(add(p, 0x24a0), 0x30322037382e35312035332e32382038312e3332203131372e373620322e3738)
            mstore(add(p, 0x24c0), 0x2036372e32392d31392e3634203131372e37362d37322e39203135312e34312d)
            mstore(add(p, 0x24e0), 0x35332e32372033332e36342d3130392e33362035302e34362d3137332e383320)
            mstore(add(p, 0x2500), 0x35302e34362d36342e353120302d3132302e35382d32322e34332d3136382e32)
            mstore(add(p, 0x2520), 0x342d37302e30392d34372e36372d34372e36382d37302e312d3130332e37342d)
            mstore(add(p, 0x2540), 0x37302e312d3136382e323420302d36342e34382032322e34332d3132302e3536)
            mstore(add(p, 0x2560), 0x2037302e312d3136382e32312034372e36362d34372e3637203134302e31382d)
            mstore(add(p, 0x2580), 0x38392e3733203238302e33382d3133312e3738203132362e31372d34322e3036)
            mstore(add(p, 0x25a0), 0x203235322e33342d3131342e3935203337382e35312d3232312e352d3132362e)
            mstore(add(p, 0x25c0), 0x3137203230372e34372d3233352e3532203332322e34342d3332352e32342033)
            mstore(add(p, 0x25e0), 0x34372e36372d39322e35322032352e32332d3137312e30332034372e36362d32)
            mstore(add(p, 0x2600), 0x34312e31322036372e32392d37302e30392031392e36322d3130362e35352035)
            mstore(add(p, 0x2620), 0x362e30392d3130362e3535203130362e353420302035302e34382031362e3831)
            mstore(add(p, 0x2640), 0x2039322e35342035332e3237203132382e393727207374796c653d2766696c6c)
            mstore(add(p, 0x2660), 0x3a23303939346433272f3e3c636972636c652063783d2736313630272063793d)
            mstore(add(p, 0x2680), 0x27333035302720723d2736303027207374796c653d2766696c6c3a2333313262)
            mstore(add(p, 0x26a0), 0x3564272f3e3c7061746820643d274d3731343520313732326335392030203130)
            mstore(add(p, 0x26c0), 0x3920323620313531203736203431203530203631203131332036312031383573)
            mstore(add(p, 0x26e0), 0x2d3139203133352d363120313835632d34312035302d313230203134342d3233)
            mstore(add(p, 0x2700), 0x36203237392d32322032362d34312034362d35392035392d31372d31332d3337)
            mstore(add(p, 0x2720), 0x2d33332d35392d35392d3131362d3133352d3139342d3232392d3233362d3237)
            mstore(add(p, 0x2740), 0x392d34312d35302d36332d3131332d36312d3138352d322d37322032302d3133)
            mstore(add(p, 0x2760), 0x352036312d3138362034312d35302039322d3736203135312d37362035352030)
            mstore(add(p, 0x2780), 0x203130332032342031343420373027207374796c653d2766696c6c3a23333132)
            mstore(add(p, 0x27a0), 0x623564272f3e3c75736520786c696e6b3a687265663d27237465657468272073)
            mstore(add(p, 0x27c0), 0x74796c653d2766696c6c3a23666666272f3e0000000000000000000000000000)
            mstore(add(p, 0x27d2), "<use xlink:href='#decorative")

            p := add(p, 0x27ee)
            mstore8(p, 0x30) // "0"
            if mod(seed, 3) {
                mstore8(p, add(0x30, mod(seed, 3))) // "1" or "2"
            }
            p := add(p, 0x01)
            seed := shr(8, seed)

            let temp := "'/><use xlink:href='#decorative"
            mstore(p, temp)
            p := add(p, 31)

            mstore8(p, 0x30) // "0"
            if mod(seed, 3) {
                mstore8(p, add(0x32, mod(seed, 3))) // "3" or "4"
            }
            p := add(p, 0x01)
            seed := shr(8, seed)

            mstore(p, temp)
            p := add(p, 31)

            mstore8(p, 0x30) // "0"
            if mod(seed, 3) {
                mstore8(p, add(0x34, mod(seed, 3))) // "5" or "6"
            }
            p := add(p, 0x01)
            seed := shr(8, seed)

            mstore(p, temp)
            p := add(p, 31)
            mstore8(p, 0x30) // "0"
            if mod(seed, 3) {
                mstore8(p, add(0x36, mod(seed, 3))) // "7" or "8"
            }
            p := add(p, 1)
            seed := shr(8, seed)

            mstore(p, "'/></g></defs><g filter='invert(")
            p := add(p, 32)
            {
                mstore8(p, add(0x30, and(seed, 1))) // "0" or "1"
                mstore(add(p, 1), ') hue-rotate(')
                seed := shr(1, seed)
                let hue := mul(30, mod(seed, 12)) // 0 to 360 in steps of 12
                mstore8(add(p, 0xe), add(0x30, mod(div(hue, 100), 10)))
                mstore8(add(p, 0xf), add(0x30, mod(div(hue, 10), 10)))
                mstore8(add(p, 0x10), add(0x30, mod(hue, 10)))
            }
            p := add(p, 17)

            let eye1 := add(0x31, and(seed, 1)) // "1" or "2"
            let hasMixedEyes := eq(mod(shr(1, seed), 10), 0)
            let eye2
            switch hasMixedEyes
            case 1 {
                eye2 := or(and(eye1, not(3)), and(3, xor(eye1, 3)))
            }
            case 0 {
                eye2 := eye1
            }
            seed := shr(16, seed)

            mstore(p, "deg)'><use xlink:href='#face'/><")
            mstore(add(p, 32), "use xlink:href='#eye")

            p := add(p, 52)

            mstore8(p, eye1) // "1" or "2"
            mstore(add(p, 1), "' style='fill:#")
            let color1
            let color2
            switch and(seed, 1)
            case 1 {
                color1 := '9addf0'
            }
            case 0 {
                color1 := 'ed1c24'
            }
            seed := shr(1, seed)
            switch and(seed, 1)
            case 1 {
                color2 := '9addf0'
            }
            case 0 {
                color2 := 'ed1c24'
            }
            mstore(add(p, 16), color1)

            seed := shr(16, seed)
            p := add(p, 22)

            mstore(p, "'/><use xlink:href='#half'/><g t")
            mstore(add(p, 32), "ransform='matrix(-1 0 0 1 14000 ")
            mstore(add(p, 64), "0)'><use xlink:href='#eye")

            p := add(p, 89)
            mstore8(p, eye2) // "1" or "2"
            mstore(add(p, 1), "' style='fill:#")
            mstore(add(p, 16), color2)
            seed := shr(16, seed)

            p := add(p, 22)

            mstore(p, "'/><use xlink:href='#half'/></g>")
            mstore(add(p, 32), "</g></g><text x='30' y='55' clas")
            mstore(add(p, 64), "s='heavy'>")
            p := add(p, 74)

            mstore(p, 'Week: ')
            p := add(p, 6)

            switch gt(countdown, 9)
            case 1 {
                mstore8(p, add(0x30, mod(div(countdown, 10), 10))) // 0 or 1
                mstore8(add(p, 1), add(0x30, mod(countdown, 10))) // 0 or 1
                p := add(p, 2)
            }
            case 0 {
                mstore8(p, add(0x30, mod(countdown, 10))) // 0 or 1
                p := add(p, 1)
            }
            mstore(p, "</text><text x='670' y='55' clas")
            mstore(add(p, 32), "s='heavy' text-anchor='end'>")
            p := add(p, 60)

            {
                let livingCultists := div(tokenId, 100000000) // 100 million
                switch eq(livingCultists, 0)
                case 1 {
                    mstore8(p, 0x30)
                    p := add(p, 1)
                }
                default {
                    let t := livingCultists
                    let len := 0
                    for {

                    } t {

                    } {
                        t := div(t, 10)
                        len := add(len, 1)
                    }
                    for {
                        let i := 0
                    } lt(i, len) {
                        i := add(i, 1)
                    } {
                        mstore8(add(p, sub(sub(len, 1), i)), add(mod(livingCultists, 10), 0x30))
                        livingCultists := div(livingCultists, 10)
                    }
                    p := add(p, len)
                }
            }

            mstore(p, ' Cultists Remaining')
            p := add(p, 19)
            mstore(p, "</text><text x='350' y='730' cla")
            mstore(add(p, 32), "ss='superheavy' text-anchor='mid")
            mstore(add(p, 64), "dle'>")
            p := add(p, 69)

            switch iszero(mod(seed, 10))
            case 1 {
                seed := shr(8, seed)
                switch mod(seed, 8)
                case 0 {
                    mstore(p, 'Willingly ')
                    p := add(p, 10)
                }
                case 1 {
                    mstore(p, 'Enthusiastically ')
                    p := add(p, 17)
                }
                case 2 {
                    mstore(p, 'Cravenly ')
                    p := add(p, 9)
                }
                case 3 {
                    mstore(p, 'Gratefully ')
                    p := add(p, 11)
                }
                case 4 {
                    mstore(p, 'Vicariously ')
                    p := add(p, 12)
                }
                case 5 {
                    mstore(p, 'Shockingly ')
                    p := add(p, 11)
                }
                case 6 {
                    mstore(p, 'Gruesomely ')
                    p := add(p, 11)
                }
                case 7 {
                    mstore(p, 'Confusingly ')
                    p := add(p, 12)
                }
                seed := shr(8, seed)
            }
            case 0 {
                seed := shr(16, seed)
            }

            switch mod(seed, 8)
            case 0 {
                mstore(p, 'Obliterated By')
                p := add(p, 14)
            }
            case 1 {
                mstore(p, 'Extinguished By')
                p := add(p, 15)
            }
            case 2 {
                mstore(p, 'Sacrificed In The Service Of')
                p := add(p, 28)
            }
            case 3 {
                mstore(p, 'Devoured By')
                p := add(p, 11)
            }
            case 4 {
                mstore(p, 'Ripped Apart By')
                p := add(p, 15)
            }
            case 5 {
                mstore(p, 'Erased From Existence By')
                p := add(p, 24)
            }
            case 6 {
                mstore(p, 'Vivisected Via')
                p := add(p, 14)
            }
            case 7 {
                mstore(p, 'Banished To The Void Using')
                p := add(p, 25)
            }
            seed := shr(16, seed)
            mstore(p, "</text><text x='350' y='780' cla")
            mstore(add(p, 32), "ss='superheavy' text-anchor='mid")
            mstore(add(p, 64), "dle'>")

            p := add(p, 69)
            switch eq(mod(seed, 100), 0)
            case 1 {
                // It's a one in a million shot Doc... ok 1 in 100
                mstore(p, 'The Communist Manifesto')
                p := add(p, 23)
            }
            case 0 {
                switch mod(seed, 10)
                case 0 {
                    mstore(p, 'Extreme ')
                    p := add(p, 8)
                }
                case 1 {
                    mstore(p, 'Voracious ')
                    p := add(p, 10)
                }
                case 2 {
                    mstore(p, 'Hysterical ')
                    p := add(p, 11)
                }
                case 3 {
                    mstore(p, 'Politically Indiscreet ')
                    p := add(p, 23)
                }
                case 4 {
                    mstore(p, 'Energetic ')
                    p := add(p, 10)
                }
                case 5 {
                    mstore(p, 'Ferocious ')
                    p := add(p, 10)
                }
                case 6 {
                    mstore(p, 'Lazy ')
                    p := add(p, 5)
                }
                case 7 {
                    mstore(p, 'Volcanic ')
                    p := add(p, 9)
                }
                case 8 {
                    mstore(p, 'Grossly Incompetent ')
                    p := add(p, 20)
                }
                case 9 {
                    mstore(p, 'Unrefined ')
                    p := add(p, 10)
                }

                seed := shr(16, seed)
                switch mod(seed, 15)
                case 0 {
                    mstore(p, 'Curiosity')
                    p := add(p, 9)
                }
                case 1 {
                    mstore(p, 'Canadians')
                    p := add(p, 9)
                }
                case 2 {
                    mstore(p, 'Ennui')
                    p := add(p, 5)
                }
                case 3 {
                    mstore(p, 'Gluttony')
                    p := add(p, 8)
                }
                case 4 {
                    mstore(p, 'Ballroom Dancing Fever')
                    p := add(p, 22)
                }
                case 5 {
                    mstore(p, 'Heavy Metal')
                    p := add(p, 11)
                }
                case 6 {
                    mstore(p, 'Physics')
                    p := add(p, 7)
                }
                case 7 {
                    mstore(p, 'Memes')
                    p := add(p, 5)
                }
                case 8 {
                    mstore(p, 'Foolishness')
                    p := add(p, 11)
                }
                case 9 {
                    mstore(p, 'Saxophonists')
                    p := add(p, 12)
                }
                case 10 {
                    mstore(p, 'FOMO')
                    p := add(p, 4)
                }
                case 11 {
                    mstore(p, 'Velociraptors')
                    p := add(p, 13)
                }
                case 12 {
                    mstore(p, 'Theatre Critics')
                    p := add(p, 15)
                }
                case 13 {
                    mstore(p, 'Lawyers')
                    p := add(p, 7)
                }
                case 14 {
                    mstore(p, 'Explosions')
                    p := add(p, 10)
                }
                case 15 {
                    mstore(p, 'Gigawatt Lasers')
                    p := add(p, 15)
                }
            }
            mstore(p, '</text></svg>')
            p := add(p, 13)

            mstore(res, sub(sub(p, res), 0x20))
            mstore(0x40, p)
        }
    }

    function tokenURI(uint256 tokenId) public pure override returns (string memory) {
        string memory img = getImgData(tokenId);
        return
            Base64.encode(
                bytes(
                    string(
                        abi.encodePacked(
                            '{"name": "Cultist #',
                            toString(tokenId % 1000000),
                            '", "description": "Doom Cult Society is an interactive cult simulator. Acquire and sacrifice cultists to hasten the end of the world.", "image": "data:image/svg+xml;base64,',
                            Base64.encode(bytes(img)),
                            '"}'
                        )
                    )
                )
            );
    }

    function imageURI(uint256 tokenId) public pure returns (string memory) {
        string memory img = getImgData(tokenId);
        return string(abi.encodePacked('data:image/svg+xml;base64,', Base64.encode(bytes(img))));
    }

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return '0';
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return '';

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}
