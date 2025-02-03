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
        (bool success,) = payable(address(vault)).call{value: 1e18}("");
        vm.stopPrank();
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
    }
}
