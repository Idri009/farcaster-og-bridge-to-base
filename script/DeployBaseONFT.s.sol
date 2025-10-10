// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { FarcasterOGBase } from "../src/FarcasterOGBase.sol";

contract DeployBaseONFT is Script {
    address constant BASE_ENDPOINT = 0x1a44076050125825900e736c501f859c50fE728c;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        FarcasterOGBase onft = new FarcasterOGBase("Farcaster OG", "FCOG", BASE_ENDPOINT, deployer);

        console.log("Deployed FarcasterOGBase:", address(onft));

        vm.stopBroadcast();
    }
}
