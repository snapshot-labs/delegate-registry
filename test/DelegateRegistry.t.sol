// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import {Test, console} from "forge-std/Test.sol";
import {DelegateRegistry} from "../src/DelegateRegistry.sol";

contract DelegateTest is Test {
    DelegateRegistry public registry;
    bytes32 id = bytes32(keccak256(abi.encode("test")));
    address delegate = address(0x111);

    function setUp() public {
        registry = new DelegateRegistry();
    }

    function test_Delegate() public {
        assertEq(registry.delegatorCount(delegate, id), 0);
        registry.setDelegate(id, delegate);

        assertEq(registry.delegatorCount(delegate, id), 1);
        assertEq(registry.counter(id), 1);
        address[] memory delegators = registry.getDelegators(delegate, id);
        assertEq(delegators.length, 1);
        assertEq(delegators[0], address(this));
    }

    function test_DelegateTwo() public {
        assertEq(registry.delegatorCount(delegate, id), 0);
        registry.setDelegate(id, delegate);

        vm.prank(address(123));
        registry.setDelegate(id, delegate);

        assertEq(registry.delegatorCount(delegate, id), 2);
        assertEq(registry.counter(id), 2);
        assertEq(true, registry.isDelegator(delegate, id, address(this)));
        assertEq(true, registry.isDelegator(delegate, id, address(123)));
    }

    function test_ClearDelegate() public {
        assertEq(registry.delegatorCount(delegate, id), 0);
        registry.setDelegate(id, delegate);
        assertEq(true, registry.isDelegator(delegate, id, address(this)));

        address delegate2 = address(0x222);
        registry.setDelegate(id, delegate2);
        assertEq(false, registry.isDelegator(delegate, id, address(this)));
        assertEq(true, registry.isDelegator(delegate2, id, address(this)));
        assertEq(registry.counter(id), 1);

        vm.prank(address(0x123));
        registry.setDelegate(id, delegate);
        assertEq(true, registry.isDelegator(delegate, id, address(0x123)));

        assertEq(registry.delegatorCount(delegate, id), 1);
        assertEq(registry.delegatorCount(delegate2, id), 1);
        assertEq(registry.counter(id), 2);

        registry.clearDelegate(id);
        assertEq(registry.delegatorCount(delegate, id), 1);
        assertEq(registry.delegatorCount(delegate2, id), 0);
        assertEq(registry.counter(id), 1);
        assertEq(false, registry.isDelegator(delegate, id, address(this)));

        vm.prank(address(0x123));
        registry.clearDelegate(id);
        assertEq(registry.delegatorCount(delegate, id), 0);
        assertEq(false, registry.isDelegator(delegate, id, address(0x123)));
    }

    function test_ClearNullDelegate() public {
        vm.expectRevert("No delegate set");
        registry.clearDelegate(id);
    }
}
