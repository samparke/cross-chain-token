// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IToken} from "./interfaces/IToken.sol";
import {Token} from "./Token.sol";

contract Vault {
    error Vault__CannotRedeemMoreThanDeposited();
    error Vault__RedeemFailed();

    IToken private immutable i_token;
    mapping(address user => uint256 amount) private s_amountDeposited;

    event Vault__Deposit(address indexed user, uint256 amount);
    event Vault__Redeem(address indexed user, uint256 amount);

    constructor(IToken token) {
        i_token = token;
    }

    receive() external payable {}

    function deposit() external payable {
        s_amountDeposited[msg.sender] += msg.value;
        i_token.mint(msg.sender, msg.value);
        emit Vault__Deposit(msg.sender, msg.value);
    }

    function redeem(uint256 _amount) external {
        if (_amount < s_amountDeposited[msg.sender]) {
            revert Vault__CannotRedeemMoreThanDeposited();
        }
        s_amountDeposited[msg.sender] -= _amount;
        i_token.burn(msg.sender, _amount);
        (bool success,) = payable(msg.sender).call{value: _amount}("");
        if (!success) {
            revert Vault__RedeemFailed();
        }
    }
}
