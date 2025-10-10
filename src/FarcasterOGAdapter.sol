// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ONFT721Adapter } from "@layerzerolabs/onft-evm/contracts/onft721/ONFT721Adapter.sol";

/// @title FarcasterOGAdapter
/// @notice Wraps the Farcaster OG NFT collection for cross-chain bridging
/// @dev Deployed on Zora (EID: 30195)
contract FarcasterOGAdapter is ONFT721Adapter {
    constructor(
        address _token, // Farcaster OG NFT contract
        address _lzEndpoint, // LayerZero V2 endpoint
        address _delegate // Owner/admin address
    )
        ONFT721Adapter(_token, _lzEndpoint, _delegate)
    { }
}
