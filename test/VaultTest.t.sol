//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";
import {IToken} from "../src/interfaces/IToken.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {Vault} from "../src/Vault.sol";

contract VaultTest is Test {
    Token token;
    Vault vault;
    address user = makeAddr("user");
    uint256 public constant STARTING_USER_BALANCE = 100 ether;

    modifier deposit() {
        vm.prank(user);
        vault.deposit{value: 1 ether}();
        _;
    }

    function setUp() public {
        token = new Token();
        token.grantMintAndBurnRole(address(this));
        vault = new Vault(IToken(address(token)));
        token.grantMintAndBurnRole(address(vault));
        vm.deal(user, STARTING_USER_BALANCE);
    }

    // deposit
    function testDepositIncreasesUserTokenBalance() public {
        uint256 userTokensBeforeDeposit = token.balanceOf(user);
        assertEq(userTokensBeforeDeposit, 0);
        vm.prank(user);

        vm.expectEmit(true, false, false, true);
        emit Vault.Vault__Deposit(user, 1 ether);
        vault.deposit{value: 1 ether}();
        assertEq(vault.getDepositAmount(user), 1 ether);
        uint256 userTokensAfterDeposit = token.balanceOf(user);
        assertEq(userTokensAfterDeposit, 1 ether);
    }

    // redeem

    function testUserCannotRedeemMoreThanDeposited() public {
        vm.prank(user);
        vm.expectRevert(Vault.Vault__CannotRedeemMoreThanDeposited.selector);
        vault.redeem(1 ether);
    }

    function testUserRedeemsDepositedAmount() public deposit {
        assertEq(vault.getDepositAmount(user), 1 ether);
        uint256 balanceBeforeRedeem = address(user).balance;
        assertEq(balanceBeforeRedeem, STARTING_USER_BALANCE - 1 ether);
        vm.prank(user);
        vault.redeem(1 ether);
        uint256 balanceAfterRedeem = address(user).balance;
        assertEq(balanceAfterRedeem, STARTING_USER_BALANCE);
    }

    function testUserAttemtptsToRedeemUint256Max() public deposit {
        vm.prank(user);
        vault.redeem(type(uint256).max);
        assertEq(address(user).balance, STARTING_USER_BALANCE);
    }
}
