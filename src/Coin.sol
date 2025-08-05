// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Coin is ERC20, Ownable, ERC20Burnable, AccessControl {
    error Coin__MustBeMoreThanZero();
    error Coin__BalanceMustExceedOrMatchBurnAmount();

    bytes32 public constant MINT_AND_BURN_ROLE = keccak256("MINT_AND_BURN_ROLE");
    address internal immutable i_ccipAdmin;

    modifier mustBeMoreThanZero(uint256 _amount) {
        if (_amount == 0) {
            revert Coin__MustBeMoreThanZero();
        }
        _;
    }

    constructor() ERC20("Token", "TKN") Ownable(msg.sender) {}

    function grantMintAndBurnRole(address _user) external onlyOwner {
        _grantRole(MINT_AND_BURN_ROLE, _user);
    }

    function mint(address _user, uint256 _amount) external onlyRole(MINT_AND_BURN_ROLE) mustBeMoreThanZero(_amount) {
        _mint(_user, _amount);
    }

    function burn(address _user, uint256 _amount) external onlyRole(MINT_AND_BURN_ROLE) mustBeMoreThanZero(_amount) {
        if (balanceOf(_user) < _amount) {
            revert Coin__BalanceMustExceedOrMatchBurnAmount();
        }
        _burn(_user, _amount);
    }

    function getCCIPAdmin() public view returns (address) {
        return i_ccipAdmin;
    }
}
