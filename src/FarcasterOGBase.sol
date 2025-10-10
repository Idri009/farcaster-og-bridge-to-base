// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ONFT721 } from "@layerzerolabs/onft-evm/contracts/onft721/ONFT721.sol";
import { Base64 } from "solady/utils/Base64.sol";
import { LibString } from "solady/utils/LibString.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @title FarcasterOGBase
 * @notice Base chain representation of Farcaster OG NFTs
 * @dev Mints equivalent NFTs with same token IDs and IDENTICAL metadata
 * @dev This contract will be used by StrategyV2 on Base for NFT purchases/sales
 */
contract FarcasterOGBase is ONFT721, Ownable2Step {
    using LibString for uint256;

    constructor(string memory _name, string memory _symbol, address _lzEndpoint, address _delegate)
        ONFT721(_name, _symbol, _lzEndpoint, _delegate)
    { }

    /**
     * @notice Generate on-chain metadata matching original Zora contract
     * @dev Returns data URI with base64-encoded JSON, identical to Zora format
     * @dev Original: data:application/json;base64,{base64_encoded_json}
     * @dev Image stored on IPFS (decentralized, accessible from any chain)
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");

        // Generate JSON metadata (exact same format as Zora contract)
        string memory json = string(
            abi.encodePacked(
                '{"name": "Farcaster OG ',
                tokenId.toString(),
                '", "description": "Celebrating Farcaster at permissionless.", "image": "ipfs://bafybeihbx6nx4h2wblf6nlsy6nkotzqynzsrgimgqzwqgw6gf7d27ewfqu", "properties": {"number": ',
                tokenId.toString(),
                ', "name": "Farcaster OG"}}'
            )
        );

        // Encode as base64 data URI (same format as Zora)
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
    }

    /**
     * @notice Override transferOwnership to use 2-step pattern
     * @dev This prevents accidental ownership transfers to wrong addresses
     */
    function transferOwnership(address newOwner) public override(Ownable, Ownable2Step) onlyOwner {
        Ownable2Step.transferOwnership(newOwner);
    }

    /**
     * @dev Internal function - must specify both parent contracts in override
     */
    function _transferOwnership(address newOwner) internal override(Ownable, Ownable2Step) {
        Ownable2Step._transferOwnership(newOwner);
    }
}
