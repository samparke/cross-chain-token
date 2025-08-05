// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IToken {
    function mint(address user, uint256 amount) external;
    function burn(address user, uint256 amount) external;
    function grantMintAndBurnRole(address user) external;
    function balanceOf(address user) external;
}
