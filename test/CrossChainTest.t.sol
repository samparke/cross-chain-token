// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {CCIPLocalSimulatorFork} from "@chainlink/local/src/ccip/CCIPLocalSimulatorFork.sol";
import {Register} from "@chainlink/local/src/ccip/Register.sol";
import {Coin} from "../src/Coin.sol";
import {CoinPool} from "../src/CoinPool.sol";
import {Vault} from "../src/Vault.sol";
import {ICoin} from "../src/interfaces/ICoin.sol";
import {IERC20} from "@ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {RegistryModuleOwnerCustom} from "@ccip/contracts/src/v0.8/ccip/tokenAdminRegistry/RegistryModuleOwnerCustom.sol";
import {TokenAdminRegistry} from "@ccip/contracts/src/v0.8/ccip/tokenAdminRegistry/TokenAdminRegistry.sol";

contract CrossChainTest is Test {
    uint256 sepoliaFork;
    uint256 arbSepoliaFork;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address owner = makeAddr("owner");

    CCIPLocalSimulatorFork ccipLocalSimulatorFork;
    Coin sepoliaCoin;
    Coin arbSepoliaCoin;
    CoinPool sepoliaPool;
    CoinPool arbSepoliaPool;
    Vault vault;
    Register.NetworkDetails sepoliaNetworkDetails;
    Register.NetworkDetails arbSepoliaNetworkDetails;

    function setUp() public {
        address[] memory allowList = new address[](0);

        // initalising forks
        sepoliaFork = vm.createSelectFork(vm.envString("SEPOLIA_RPC_URL"));
        arbSepoliaFork = vm.createFork(vm.envString("ARB_SEPOLIA_RPC_URL"));

        // initalise ccipLocalSimulatorFork, and make it persistent across chains
        ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
        vm.makePersistent(address(ccipLocalSimulatorFork));

        // gets the network details for sepolia
        sepoliaNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);
        vm.makePersistent(sepoliaNetworkDetails.rmnProxyAddress);
        vm.makePersistent(sepoliaNetworkDetails.routerAddress);

        // deploy sepolia coin, sepolia pool and the vault
        vm.startPrank(owner);
        sepoliaCoin = new Coin();
        vault = new Vault(ICoin(address(sepoliaCoin)));
        sepoliaPool = new CoinPool(
            IERC20(address(sepoliaCoin)),
            allowList,
            sepoliaNetworkDetails.rmnProxyAddress,
            sepoliaNetworkDetails.routerAddress
        );
        sepoliaCoin.grantMintAndBurnRole(address(vault));
        sepoliaCoin.grantMintAndBurnRole(address(sepoliaPool));

        // register admin for sepolia token
        RegistryModuleOwnerCustom(sepoliaNetworkDetails.registryModuleOwnerCustomAddress).registerAdminViaOwner(
            address(sepoliaCoin)
        );
        // accept admin role
        TokenAdminRegistry(sepoliaNetworkDetails.tokenAdminRegistryAddress).acceptAdminRole(address(sepoliaCoin));
        // set the token pool
        TokenAdminRegistry(sepoliaNetworkDetails.tokenAdminRegistryAddress).setPool(
            address(sepoliaCoin), address(sepoliaPool)
        );
        vm.stopPrank();
    }
}
