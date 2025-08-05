//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Coin} from "../src/Coin.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

contract CoinTest is Test {
    Coin coin;
    address user = makeAddr("user");

    function setUp() public {
        coin = new Coin();
        coin.grantMintAndBurnRole(address(this));
    }

    // mint
    function testMintIncreasesUserBalance() public {
        uint256 userBalanceBefore = coin.balanceOf(user);

        coin.mint(user, 1 ether);
        uint256 userBalanceAfter = coin.balanceOf(user);

        assertGt(userBalanceAfter, userBalanceBefore);
    }

    function testMintMoreThanZeroRevert() public {
        vm.expectRevert(Coin.Coin__MustBeMoreThanZero.selector);

        coin.mint(user, 0 ether);
    }

    function testOnlyRoleCanMint() public {
        vm.prank(user);
        vm.expectPartialRevert(IAccessControl.AccessControlUnauthorizedAccount.selector);

        coin.mint(user, 1 ether);
    }

    // burn
    function testBurnDecreasesUserBalance() public {
        coin.mint(user, 1 ether);
        uint256 userBalanceAfterMint = coin.balanceOf(user);
        assertEq(userBalanceAfterMint, 1 ether);

        coin.burn(user, 1 ether);
        uint256 userBalanceAfterBurn = coin.balanceOf(user);
        assertEq(userBalanceAfterBurn, 0);
        assertGt(userBalanceAfterMint, userBalanceAfterBurn);
    }

    function testBurnMoreThanZeroRevert() public {
        coin.mint(user, 1 ether);
        vm.expectRevert(Coin.Coin__MustBeMoreThanZero.selector);
        coin.burn(user, 0);
    }

    function testOnlyRoleCanBurn() public {
        vm.prank(user);
        vm.expectPartialRevert(IAccessControl.AccessControlUnauthorizedAccount.selector);
        coin.burn(user, 1 ether);
    }

    function testBalanceMustExceedBurnAmount() public {
        vm.expectRevert(Coin.Coin__BalanceMustExceedOrMatchBurnAmount.selector);
        coin.burn(user, 1 ether);
    }
}
