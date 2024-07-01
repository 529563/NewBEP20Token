// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {NewBEP20token} from "../src/NewBEP20token.sol";
import {console} from "forge-std/console.sol";

contract DeployOurToken is Script {
    uint256 public DEFAULT_ANVIL_PRIVATE_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 public deployerKey;
    string public name = "NewBEP20token";
    string public symbol = "NBT";

    function run() external returns (NewBEP20token) {
        if (block.chainid == 31337) {
            deployerKey = DEFAULT_ANVIL_PRIVATE_KEY;
        } else {
            deployerKey = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(deployerKey);
        NewBEP20token newBEP20token = new NewBEP20token(name, symbol);
        vm.stopBroadcast();
        return newBEP20token;
    }
}
