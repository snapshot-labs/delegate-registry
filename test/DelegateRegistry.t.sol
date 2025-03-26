// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import {Test, console} from "forge-std/Test.sol";
import {DelegateRegistry} from "../src/DelegateRegistry.sol";

contract CounterTest is Test {
    DelegateRegistry public registry;

    function setUp() public {
        registry = new DelegateRegistry();
    }
}
