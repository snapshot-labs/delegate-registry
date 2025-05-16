// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.29;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract DelegateRegistry {
    using EnumerableSet for EnumerableSet.AddressSet;

    // The first key is the delegator and the second key an id.
    // The value is the address of the delegate
    mapping(address delegator => mapping(bytes32 id => address delegate)) public delegation;

    // The first key is the delegate and the second key an id.
    // The value is a set of delegators
    // This is used to build up a reverse lookup of delegators for a specific delegate.
    // The reverse lookup is not used in the contract itself, but it is useful for external
    // applications to build up a list of delegators for a specific delegate.
    mapping(address delegate => mapping(bytes32 id => EnumerableSet.AddressSet delegators)) private _reverseDelegation;

    // Using these events it is possible to process the events to build up reverse lookups.
    // The indices allow it to be very partial about how to build this lookup (e.g. only for a specific delegate).
    event SetDelegate(address indexed delegator, bytes32 indexed id, address indexed delegate);
    event ClearDelegate(address indexed delegator, bytes32 indexed id, address indexed delegate);

    /// @dev Sets a delegate for the msg.sender and a specific id.
    ///      The combination of msg.sender and the id can be seen as a unique key.
    /// @param id Id for which the delegate should be set
    /// @param delegate Address of the delegate
    function setDelegate(bytes32 id, address delegate) public {
        require(delegate != msg.sender, "Can't delegate to self");
        require(delegate != address(0), "Can't delegate to 0x0");
        address currentDelegate = delegation[msg.sender][id];
        require(delegate != currentDelegate, "Already delegated to this address");

        // Update delegation mapping
        delegation[msg.sender][id] = delegate;
        _reverseDelegation[delegate][id].add(msg.sender);

        if (currentDelegate != address(0)) {
            _reverseDelegation[currentDelegate][id].remove(msg.sender);
            emit ClearDelegate(msg.sender, id, currentDelegate);
        }

        emit SetDelegate(msg.sender, id, delegate);
    }

    /// @dev Clears a delegate for the msg.sender and a specific id.
    ///      The combination of msg.sender and the id can be seen as a unique key.
    /// @param id Id for which the delegate should be set
    function clearDelegate(bytes32 id) public {
        address currentDelegate = delegation[msg.sender][id];
        require(currentDelegate != address(0), "No delegate set");

        // update delegation mapping
        delegation[msg.sender][id] = address(0);
        _reverseDelegation[currentDelegate][id].remove(msg.sender);

        emit ClearDelegate(msg.sender, id, currentDelegate);
    }

    /**
     * @notice Check if an address is a delegator for a specific delegate and ID
     * @param delegate The delegate address
     * @param id The delegation ID
     * @param delegator The potential delegator to check
     * @return bool True if the address has delegated to this delegate for this ID
     */
    function isDelegator(address delegate, bytes32 id, address delegator) external view returns (bool) {
        return _reverseDelegation[delegate][id].contains(delegator);
    }
    
    /**
     * @notice Get the number of delegators for a specific delegate and ID
     * @param delegate The delegate address
     * @param id The delegation ID
     * @return uint256 Number of delegators
     */
    function delegatorCount(address delegate, bytes32 id) external view returns (uint256) {
        return _reverseDelegation[delegate][id].length();
    }
    
    /**
     * @notice Get a delegator by index for a specific delegate and ID
     * @param delegate The delegate address
     * @param id The delegation ID
     * @param index The index in the delegators array
     * @return address The delegator address at the specified index
     */
    function delegatorAt(address delegate, bytes32 id, uint256 index) external view returns (address) {
        return _reverseDelegation[delegate][id].at(index);
    }

    /**
     * @notice Get all delegators for a specific delegate and ID
     * @param delegate The delegate address
     * @param id The delegation ID
     * @return address[] Array of delegator addresses
     */
    function getDelegators(address delegate, bytes32 id) external view returns (address[] memory) {
        uint256 count = _reverseDelegation[delegate][id].length();
        address[] memory result = new address[](count);
        
        for (uint256 i = 0; i < count; i++) {
            result[i] = _reverseDelegation[delegate][id].at(i);
        }
        
        return result;
    }
}
