//SPDX-License-Identifier
pragma solidity ^0.8.24;

import {TokenPool} from "@ccip/contracts/src/v0.8/ccip/pools/TokenPool.sol";
import {Pool} from "@ccip/contracts/src/v0.8/ccip/libraries/Pool.sol";
import {IERC20} from "@ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {ICoin} from "./interfaces/ICoin.sol";
import {Vault} from "./Vault.sol";

/**
 * @notice this contract is the token pool which manages the burning/locking and minting/releasing of tokens on each chain
 * It inherits from TokenPool, mimicking functions from the BurnMintTokenPoolAbstract contract like lockOrBurn and releaseOrMint.
 * There may be a simpler approach, as we do not pass through any data like interest rates
 */
contract CoinPool is TokenPool {
    /**
     * @notice these are the parameters to send through to the token pool
     */
    constructor(IERC20 _token, address[] memory _allowList, address _rmnProxy, address _routerAddress)
        TokenPool(_token, _allowList, _rmnProxy, _routerAddress)
    {}

    /**
     * @notice this function burns tokens
     * @dev much of the functionality comes from BurnMintTokenPoolAbstract
     * we call the _validateLockOrBurn from the TokenPool contract
     * once validated, we burn the token from this address, in the amount retrieved from the lockOrBurnIn struct we passed in (amount)
     * then, lockOrBurnOut contains the address or the destination token, and any data we want to pass across
     */
    function lockOrBurn(Pool.LockOrBurnInV1 calldata lockOrBurnIn)
        external
        returns (Pool.LockOrBurnOutV1 memory lockOrBurnOut)
    {
        _validateLockOrBurn(lockOrBurnIn);
        // i_token is from IERC, not our declared token
        ICoin(address(i_token)).burn(address(this), lockOrBurnIn.amount);
        lockOrBurnOut = Pool.LockOrBurnOutV1({
            destTokenAddress: getRemoteToken(lockOrBurnIn.remoteChainSelector),
            // we aren't sending across data, such as interest rates
            destPoolData: ""
        });
    }

    /**
     * @notice this function handles the release on the secondary chain
     * @dev we call the TokenPool _validateReleaseOrMint
     * after validation, we mint the token in the releaseOrMint.amount - this should be the same as the lockOrBurnIn.amount
     * and finally, releaseOrMintOut contains the destination amount, which equals the releaseOrMintIn.amount
     */
    function releaseOrMint(Pool.ReleaseOrMintInV1 calldata releaseOrMintIn)
        external
        returns (Pool.ReleaseOrMintOutV1 memory releaseOrMintOut)
    {
        _validateReleaseOrMint(releaseOrMintIn);
        ICoin(address(i_token)).mint(address(this), releaseOrMintIn.amount);
        releaseOrMintOut = Pool.ReleaseOrMintOutV1({destinationAmount: releaseOrMintIn.amount});
    }
}
