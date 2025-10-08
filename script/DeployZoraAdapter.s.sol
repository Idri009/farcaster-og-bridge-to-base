// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {FarcasterOGAdapter} from "../src/FarcasterOGAdapter.sol";

contract DeployZoraAdapter is Script {
    address constant FARCASTER_OG = 0xe03Ef4B9db1A47464De84fb476f9bAf493B3E886;
    address constant ZORA_ENDPOINT = 0x1a44076050125825900e736c501f859c50fE728c;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        FarcasterOGAdapter adapter = new FarcasterOGAdapter(
            FARCASTER_OG,
            ZORA_ENDPOINT,
            deployer
        );

        console.log("Deployed FarcasterOGAdapter:", address(adapter));

        vm.stopBroadcast();
    }
}
