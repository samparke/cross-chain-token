// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Token is ERC20, Ownable, ERC20Burnable, AccessControl {
    error Token__MustBeMoreThanZero();
    error Token__BurnAmountMustExceedBalance();

    bytes32 public constant MINT_AND_BURN_ROLE = keccak256("MINT_AND_BURN_ROLE");

    modifier mustBeMoreThanZero(uint256 _amount) {
        if (_amount == 0) {
            revert Token__MustBeMoreThanZero();
        }
        _;
    }

    constructor() ERC20("Token", "TKN") Ownable(msg.sender) {}

    function grantMintAndBurnRole(address _user) external onlyOwner {
        grantRole(MINT_AND_BURN_ROLE, _user);
    }

    function mint(address _user, uint256 _amount) public onlyOwner mustBeMoreThanZero(_amount) {
        _mint(_user, _amount);
    }

    function burn(uint256 _amount) public override mustBeMoreThanZero(_amount) {
        if (balanceOf(msg.sender) < _amount) {
            revert Token__BurnAmountMustExceedBalance();
        }
        super.burn(_amount);
    }
}
