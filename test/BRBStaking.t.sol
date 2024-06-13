pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/BRBStaking.sol";
import "../src/BRBToken.sol";

contract StakingContractTest is Test{
    BRBStaking stakingContract;
    BRBToken token;
    
    // Actors
    address owner;
    address user;

    function setUp() public {
        owner = address(0x111);
        user = address(0x222);

        vm.startPrank(owner);

        token = new BRBToken(owner);
        stakingContract = new BRBStaking(token);

        token.transfer(user, 1000 ether);
        vm.stopPrank();
    }

    // User should be able to initialize their staking profile - JUST ONCE
    function testInitializeUserTwice() public{

        vm.startPrank(user);
        stakingContract.initializeUser();

        vm.expectRevert("User already initialized");
        stakingContract.initializeUser();

        vm.stopPrank();
        
    }
    // TEST initializeUser() function
    function testInitializeUser() public {
        // Prank as user
        vm.prank(user);
        stakingContract.initializeUser();

        // Verify user initialization
        (address userAddress, , bool initialized, ,) = stakingContract.userStakeData(user, 0);
        assertEq(userAddress, user);
        assertTrue(initialized);
    }

    // Test stake() function
    function testStake() public {
        uint256 stakeAmount = 100 * 10**18;

        // Prank as user to approve and stake
        vm.startPrank(user);
        token.approve(address(stakingContract), stakeAmount);
        stakingContract.initializeUser();
        stakingContract.stake(stakeAmount);

        vm.stopPrank(); 
        // Verify staking
        (address userAddress, uint256 stakeAmountStored, bool initialized, ,uint256 stakeID) = stakingContract.userStakeData(user, 1);
        assertEq(userAddress, user);
        assertEq(stakeAmountStored, stakeAmount);
        assertEq(stakeID, 1);
        assertTrue(initialized);
    }
}