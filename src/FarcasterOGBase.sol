// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ONFT721} from "@layerzerolabs/onft-evm/contracts/onft721/ONFT721.sol";
import {Base64} from "solady/utils/Base64.sol";
import {LibString} from "solady/utils/LibString.sol";

/// @title FarcasterOGBase
/// @notice Bridged representation of Farcaster OG NFTs on Base
/// @dev Deployed on Base (EID: 30184)
contract FarcasterOGBase is ONFT721 {
    using LibString for uint256;

    constructor(
        string memory _name,
        string memory _symbol,
        address _lzEndpoint,
        address _delegate
    ) ONFT721(_name, _symbol, _lzEndpoint, _delegate) {}

    /// @notice Returns on-chain metadata matching the original Zora contract
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");

        string memory json = string(abi.encodePacked(
            '{"name":"Farcaster OG ',
            tokenId.toString(),
            '","description":"Celebrating Farcaster at permissionless.",',
            '"image":"ipfs://bafybeihbx6nx4h2wblf6nlsy6nkotzqynzsrgimgqzwqgw6gf7d27ewfqu",',
            '"properties":{"number":',
            tokenId.toString(),
            ',"name":"Farcaster OG"}}'
        ));

        return string(abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(bytes(json))
        ));
    }
}
