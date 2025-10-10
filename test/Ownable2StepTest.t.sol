// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import { FarcasterOGBase } from "../src/FarcasterOGBase.sol";

/// @notice Minimal mock LayerZero endpoint for testing
/// @dev Only implements methods called during ONFT721 construction
contract MockLayerZeroEndpoint {
    mapping(address => address) public delegates;

    function setDelegate(address _delegate) external {
        delegates[msg.sender] = _delegate;
    }

    // Stub for any other calls that might happen
    fallback() external payable { }

    // Added receive function to handle plain ether transfers
    receive() external payable { }
}

/// @title Ownable2StepTest
/// @notice Tests that FarcasterOGBase properly implements Ownable2Step pattern
/// @dev Verifies ownership transfers require explicit acceptance by the new owner
contract Ownable2StepTest is Test {
    FarcasterOGBase public nft;
    MockLayerZeroEndpoint public mockEndpoint;

    address public originalOwner;
    address public newOwner;
    address public unauthorizedUser;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setUp() public {
        originalOwner = address(this);
        newOwner = makeAddr("newOwner");
        unauthorizedUser = makeAddr("unauthorizedUser");

        // Deploy mock LayerZero endpoint
        mockEndpoint = new MockLayerZeroEndpoint();

        // Deploy FarcasterOGBase with original owner as delegate
        nft = new FarcasterOGBase("Farcaster OG", "FCOG", address(mockEndpoint), originalOwner);
    }

    /// @notice Test successful 2-step ownership transfer
    /// @dev Verifies that new owner can accept and become owner
    function test_OwnershipTransfer_Success() public {
        // Verify initial owner
        assertEq(nft.owner(), originalOwner, "Initial owner should be originalOwner");
        assertEq(nft.pendingOwner(), address(0), "Should have no pending owner initially");

        // Step 1: Current owner initiates transfer
        vm.expectEmit(true, true, false, false);
        emit OwnershipTransferStarted(originalOwner, newOwner);
        nft.transferOwnership(newOwner);

        // Verify pending state
        assertEq(nft.owner(), originalOwner, "Owner should still be original during pending");
        assertEq(nft.pendingOwner(), newOwner, "Pending owner should be set");

        // Step 2: New owner accepts ownership
        vm.expectEmit(true, true, false, false);
        emit OwnershipTransferred(originalOwner, newOwner);
        vm.prank(newOwner);
        nft.acceptOwnership();

        // Verify ownership transferred
        assertEq(nft.owner(), newOwner, "Owner should be newOwner after acceptance");
        assertEq(nft.pendingOwner(), address(0), "Pending owner should be cleared");
    }

    /// @notice Test that unauthorized user cannot accept ownership
    /// @dev Verifies that only pending owner can call acceptOwnership
    function test_OwnershipTransfer_UnauthorizedAcceptance_Reverts() public {
        // Step 1: Initiate transfer to newOwner
        nft.transferOwnership(newOwner);

        // Verify pending state
        assertEq(nft.pendingOwner(), newOwner, "Pending owner should be newOwner");

        // Step 2: Unauthorized user tries to accept
        vm.prank(unauthorizedUser);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", unauthorizedUser));
        nft.acceptOwnership();

        // Verify state unchanged
        assertEq(nft.owner(), originalOwner, "Owner should remain unchanged");
        assertEq(nft.pendingOwner(), newOwner, "Pending owner should remain unchanged");
    }

    /// @notice Test that ownership doesn't transfer without acceptance
    /// @dev Verifies that calling transferOwnership alone doesn't change owner
    function test_OwnershipTransfer_RemainingPending() public {
        // Initial state
        assertEq(nft.owner(), originalOwner, "Initial owner should be originalOwner");

        // Initiate transfer
        nft.transferOwnership(newOwner);

        // Verify owner hasn't changed yet
        assertEq(nft.owner(), originalOwner, "Owner should not change until accepted");
        assertEq(nft.pendingOwner(), newOwner, "Pending owner should be set");

        // Original owner should still have control
        vm.prank(originalOwner);
        nft.transferOwnership(unauthorizedUser); // Can change pending owner

        assertEq(nft.owner(), originalOwner, "Owner should still be original");
        assertEq(nft.pendingOwner(), unauthorizedUser, "Pending owner should be updated");
    }

    /// @notice Test that original owner cannot accept their own transfer
    /// @dev Edge case: original owner tries to accept when they're not pending
    function test_OwnershipTransfer_OriginalOwnerCannotAccept() public {
        // Initiate transfer to newOwner
        nft.transferOwnership(newOwner);

        // Original owner tries to accept (but they're not pending owner)
        vm.prank(originalOwner);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", originalOwner));
        nft.acceptOwnership();

        // Verify state unchanged
        assertEq(nft.owner(), originalOwner, "Owner should remain unchanged");
        assertEq(nft.pendingOwner(), newOwner, "Pending owner should remain unchanged");
    }

    /// @notice Test canceling ownership transfer by setting to address(0)
    /// @dev Verifies that transfer can be canceled before acceptance
    function test_OwnershipTransfer_Cancel() public {
        // Initiate transfer
        nft.transferOwnership(newOwner);
        assertEq(nft.pendingOwner(), newOwner, "Pending owner should be set");

        // Cancel by transferring to address(0)
        nft.transferOwnership(address(0));

        // Verify canceled (pending owner is address(0))
        assertEq(nft.owner(), originalOwner, "Owner should remain original");
        assertEq(nft.pendingOwner(), address(0), "Pending owner should be cleared");

        // Now nobody can accept
        vm.prank(newOwner);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", newOwner));
        nft.acceptOwnership();
    }
}
