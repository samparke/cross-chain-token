//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

contract TokenTest is Test {
    Token token;
    address user = makeAddr("user");

    function setUp() public {
        token = new Token();
        token.grantMintAndBurnRole(address(this));
    }

    // mint
    function testMintIncreasesUserBalance() public {
        uint256 userBalanceBefore = token.balanceOf(user);

        token.mint(user, 1 ether);
        uint256 userBalanceAfter = token.balanceOf(user);

        assertGt(userBalanceAfter, userBalanceBefore);
    }

    function testMintMoreThanZeroRevert() public {
        vm.expectRevert(Token.Token__MustBeMoreThanZero.selector);

        token.mint(user, 0 ether);
    }

    function testOnlyRoleCanMint() public {
        vm.prank(user);
        vm.expectPartialRevert(IAccessControl.AccessControlUnauthorizedAccount.selector);

        token.mint(user, 1 ether);
    }

    // burn
    function testBurnDecreasesUserBalance() public {
        token.mint(user, 1 ether);
        uint256 userBalanceAfterMint = token.balanceOf(user);
        assertEq(userBalanceAfterMint, 1 ether);

        token.burn(user, 1 ether);
        uint256 userBalanceAfterBurn = token.balanceOf(user);
        assertEq(userBalanceAfterBurn, 0);
        assertGt(userBalanceAfterMint, userBalanceAfterBurn);
    }

    function testBurnMoreThanZeroRevert() public {
        token.mint(user, 1 ether);
        vm.expectRevert(Token.Token__MustBeMoreThanZero.selector);
        token.burn(user, 0);
    }

    function testOnlyRoleCanBurn() public {
        vm.prank(user);
        vm.expectPartialRevert(IAccessControl.AccessControlUnauthorizedAccount.selector);
        token.burn(user, 1 ether);
    }

    function testBalanceMustExceedBurnAmount() public {
        vm.expectRevert(Token.Token__BalanceMustExceedOrMatchBurnAmount.selector);
        token.burn(user, 1 ether);
    }
}
