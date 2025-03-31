// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import {Test, console} from "forge-std/Test.sol";
import {DelegateRegistry} from "../src/DelegateRegistry.sol";

contract CounterTest is Test {
    DelegateRegistry public registry;
    bytes32 id = bytes32(keccak256(abi.encode("test")));
    address delegator = address(0x111);

    function setUp() public {
        registry = new DelegateRegistry();
    }

    function test_Delegate() public {
        assertEq(registry.counter(delegator, id), 0);
        registry.setDelegate(id, delegator);

        assertEq(registry.counter(delegator, id), 1);
    }

    function test_DelegateTwo() public {
        assertEq(registry.counter(delegator, id), 0);
        registry.setDelegate(id, delegator);

        vm.prank(address(123));
        registry.setDelegate(id, delegator);

        assertEq(registry.counter(delegator, id), 2);
    }

    function test_ClearDelegate() public {
        assertEq(registry.counter(delegator, id), 0);
        registry.setDelegate(id, delegator);

        vm.prank(address(123));
        registry.setDelegate(id, delegator);

        assertEq(registry.counter(delegator, id), 2);

        registry.clearDelegate(id);
        assertEq(registry.counter(delegator, id), 1);

        vm.prank(address(123));
        registry.clearDelegate(id);
        assertEq(registry.counter(delegator, id), 0);
    }

    function test_ClearNullDelegate() public {
        vm.expectRevert("No delegate set");
        registry.clearDelegate(id);
    }
}
