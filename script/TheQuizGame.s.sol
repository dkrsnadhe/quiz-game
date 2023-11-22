// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console2} from "forge-std/Script.sol";
import {TheQuizGame} from "../src/TheQuizGame.sol";

contract TheQuizGameScript is Script {
    TheQuizGame public theQuizGame;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        theQuizGame = new TheQuizGame();
        vm.stopBroadcast();
    }
}
