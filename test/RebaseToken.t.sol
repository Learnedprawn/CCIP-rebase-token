//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {RebaseToken} from "../src/RebaseToken.sol";
import {Vault} from "../src/Vault.sol";
import {IRebaseToken} from "../src/Interfaces/IRebaseToken.sol";

contract RebaseTokenTest is Test {
    RebaseToken private rebaseToken;
    Vault private vault;

    address public OWNER = makeAddr("OWNER");
    address public USER = makeAddr("USER");

    function setUp() public {
        vm.startPrank(OWNER);
        rebaseToken = new RebaseToken();
        vault = new Vault(IRebaseToken(address(rebaseToken)));
        rebaseToken.grantMintAndBurnRole(address(vault));
        (bool success , ) = payable(address(vault)).call{value: 1e18}("");
        console.log("Vault Creation Success: ", success);
        vm.stopPrank();
    }

    function addRewardsToVault(uint256 _rewardAmount) public {
        (bool success,) = payable(address(vault)).call{value: _rewardAmount}("");
        console.log("Reward Addition Success: ", success);

    }

    function test_DepositLinear(uint256 _amount) public {
        _amount = bound(_amount, 1e5, type(uint96).max);
        vm.startPrank(USER);
        vm.deal(USER, _amount);
        vault.deposit{value: _amount}();
        uint256 startingBalance = rebaseToken.balanceOf(USER);
        console.log("Starting Balance: ", startingBalance);
        assertEq(startingBalance, _amount);
        vm.warp(block.timestamp + 1 hours);
        uint256 middleBalance = rebaseToken.balanceOf(USER);
        assertGt(middleBalance, startingBalance);
        console.log("Middle Balance: ", middleBalance);
        vm.warp(block.timestamp + 1 hours);
        uint256 endingBalance = rebaseToken.balanceOf(USER);
        assertGt(endingBalance, middleBalance);

        assertApproxEqAbs(endingBalance - middleBalance, middleBalance - startingBalance, 1);

        vm.stopPrank();
    }

    function test_RedeemStraightAway(uint256 _amount) public {
        _amount = bound(_amount, 1e5, type(uint96).max);
        vm.startPrank(USER);
        vm.deal(USER, _amount);
        vault.deposit{value: _amount}();
        assertEq(rebaseToken.balanceOf(USER), _amount);
        vault.redeem(type(uint256).max);
        assertEq(rebaseToken.balanceOf(USER), 0);
        assertEq(address(USER).balance, _amount);
        vm.stopPrank();
    }

    function test_RedeemAfterTimePassed(uint256 _depositAmount, uint256 _time) public {
        _time = bound(_time, 1000, type(uint32).max);
        _depositAmount = bound(_depositAmount, 1e5, type(uint96).max);
        vm.deal(USER, _depositAmount);
        vm.prank(USER);
        vault.deposit{value: _depositAmount}();
        assertEq(rebaseToken.balanceOf(USER), _depositAmount);
        vm.warp(block.timestamp + _time);
        uint256 balanceAfterSomeTime = rebaseToken.balanceOf(USER);
        vm.deal(OWNER, balanceAfterSomeTime-_depositAmount);
        vm.prank(OWNER);
        addRewardsToVault(balanceAfterSomeTime-_depositAmount);
        vm.prank(USER);
        vault.redeem(type(uint256).max);
        assertEq(rebaseToken.balanceOf(USER), 0);
        assertGt(address(USER).balance, _depositAmount);
        vm.stopPrank();
    }

    function test_Transfer(uint256 _amount, uint256 _amountToSend) public {
        _amount = bound(_amount, 2e5, type(uint96).max);
        _amountToSend = bound(_amountToSend, 1e5, _amount - 1e5);
        vm.deal(USER, _amount);
        vm.prank(USER);
        vault.deposit{value: _amount}();
        address user2 = makeAddr("USER2");
        uint256 user2Balance = rebaseToken.balanceOf(user2);
        uint256 userBalance = rebaseToken.balanceOf(USER);
        assertEq(userBalance, _amount);
        assertEq(user2Balance, 0);
        vm.prank(OWNER);
        rebaseToken.setInterestRate(4e10);
        vm.prank(USER);
        rebaseToken.transfer(user2, _amountToSend);
        uint256 user2BalanceAfterTransfer = rebaseToken.balanceOf(user2);
        uint256 userBalanceAfterTransfer = rebaseToken.balanceOf(USER);
        assertEq(userBalanceAfterTransfer, userBalance - _amountToSend);
        assertEq(user2BalanceAfterTransfer, _amountToSend);
        assertEq(rebaseToken.getUserInterestRate(USER), 5e10);
        assertEq(rebaseToken.getUserInterestRate(user2), 5e10);
    }

     function test_CannotSetInterestRate(uint256 newInterestRate) public {
        // Update the interest rate
        vm.startPrank(USER);
        vm.expectRevert();
        rebaseToken.setInterestRate(newInterestRate);
        vm.stopPrank();
    }
}
