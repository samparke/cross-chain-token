// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ICoin} from "./interfaces/ICoin.sol";
import {Coin} from "./Coin.sol";

contract Vault {
    error Vault__CannotRedeemMoreThanDeposited();
    error Vault__RedeemFailed();

    ICoin private immutable i_coin;
    mapping(address user => uint256 amount) private s_amountDeposited;

    event Vault__Deposit(address indexed user, uint256 amount);
    event Vault__Redeem(address indexed user, uint256 amount);

    constructor(ICoin coin) {
        i_coin = coin;
    }

    receive() external payable {}

    function deposit() external payable {
        s_amountDeposited[msg.sender] += msg.value;
        i_coin.mint(msg.sender, msg.value);
        emit Vault__Deposit(msg.sender, msg.value);
    }

    function redeem(uint256 _amount) external {
        if (_amount == type(uint256).max) {
            _amount = i_coin.balanceOf(msg.sender);
        }
        if (_amount > s_amountDeposited[msg.sender]) {
            revert Vault__CannotRedeemMoreThanDeposited();
        }

        s_amountDeposited[msg.sender] -= _amount;
        i_coin.burn(msg.sender, _amount);
        (bool success,) = payable(msg.sender).call{value: _amount}("");
        if (!success) {
            revert Vault__RedeemFailed();
        }
    }

    function getDepositAmount(address _user) external view returns (uint256) {
        return s_amountDeposited[_user];
    }
}
