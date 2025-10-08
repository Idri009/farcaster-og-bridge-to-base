// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {FarcasterOGAdapter} from "../src/FarcasterOGAdapter.sol";
import {FarcasterOGBase} from "../src/FarcasterOGBase.sol";

contract ConfigurePeers is Script {
    uint32 constant ZORA_EID = 30195;
    uint32 constant BASE_EID = 30184;

    function run() external {
        address zoraAdapter = vm.envAddress("ZORA_ADAPTER");
        address baseOnft = vm.envAddress("BASE_ONFT");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Configure Zora → Base peer
        vm.createSelectFork(vm.envString("ZORA_RPC_URL"));
        vm.startBroadcast(deployerPrivateKey);

        FarcasterOGAdapter(zoraAdapter).setPeer(
            BASE_EID,
            bytes32(uint256(uint160(baseOnft)))
        );

        vm.stopBroadcast();

        // Configure Base → Zora peer
        vm.createSelectFork(vm.envString("BASE_RPC_URL"));
        vm.startBroadcast(deployerPrivateKey);

        FarcasterOGBase(baseOnft).setPeer(
            ZORA_EID,
            bytes32(uint256(uint160(zoraAdapter)))
        );

        vm.stopBroadcast();

        console.log("Peers configured successfully");
    }
}
