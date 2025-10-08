# Farcaster OG Bridge

Cross-chain NFT bridge for Farcaster OG collection (Zora ↔ Base) using LayerZero V2.

## Architecture

- **Zora**: `FarcasterOGAdapter` locks original NFTs
- **Base**: `FarcasterOGBase` mints/burns bridged NFTs
- Token IDs are preserved across chains

## Deployed Contracts

| Network | Contract | Address |
|---------|----------|---------|
| Zora | FarcasterOGAdapter | TBD |
| Base | FarcasterOGBase | TBD |

## Build

```bash
forge install
forge build
```

## Deploy

```bash
# 1. Deploy adapter on Zora
forge script script/DeployZoraAdapter.s.sol --rpc-url $ZORA_RPC_URL --broadcast --verify

# 2. Deploy ONFT on Base
forge script script/DeployBaseONFT.s.sol --rpc-url $BASE_RPC_URL --broadcast --verify

# 3. Configure peers
export ZORA_ADAPTER=<adapter_address>
export BASE_ONFT=<onft_address>
forge script script/ConfigurePeers.s.sol --broadcast
```

## Bridge Usage

### Approve & Bridge from Zora

```solidity
// 1. Approve adapter
IERC721(farcasterOG).approve(adapterAddress, tokenId);

// 2. Get fee quote
MessagingFee memory fee = adapter.quoteSend(sendParam, false);

// 3. Bridge (with 400% fee buffer for reliability)
adapter.send{value: fee.nativeFee * 5}(sendParam, fee, msg.sender);
```

### Track

Monitor cross-chain message delivery on [LayerZeroScan](https://layerzeroscan.com)

## Security

- Only LayerZero Endpoint can mint on Base
- Only configured peer messages accepted
- Token supply controlled via bridge flow
- No public mint function exists

## Links

- [LayerZero V2 Docs](https://docs.layerzero.network/v2/developers/evm/onft/quickstart)
- [Original Collection](https://zora.co/collect/zora:0xe03ef4b9db1a47464de84fb476f9baf493b3e886)
- [LayerZero Endpoint V2](https://docs.layerzero.network/v2/developers/evm/technical-reference/deployed-contracts)

## License

MIT
