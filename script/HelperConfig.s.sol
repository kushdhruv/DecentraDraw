//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {VRFCoordinatorV2Mock } from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
contract HelperConfig is Script {

    uint256 public constant ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
        address link;
        uint256 deployerKey;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if(block.chainid == 11155111) { // Sepolia
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 31337) { // Anvil
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        } else {
            revert("Unsupported network");
        }
    }

    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            entranceFee : 0.01 ether,
            interval : 30,
            vrfCoordinator :0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            gasLane :0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 0, //update with our subscription ID
            callbackGasLimit : 500000, //500,000 gas!
            link:0x779877A7B0D9E8603169DdbD7836e478b4624789,
            deployerKey: vm.envUint("PRIVATE_KEY") // This is the deployer key for Sepolia
        });
    }
    function getOrCreateAnvilEthConfig()public returns (NetworkConfig memory) {
        if(activeNetworkConfig.vrfCoordinator != address(0)) // means we have already set the config
        {
            return activeNetworkConfig; // already set
        }
        // deploy VRFCoordinatorV2Mock
        uint96 baseFee = 0.25 ether; // 0.25 LINK per request
        uint96 gasPriceLink = 1e9 ether; // 1gwei per gas
        LinkToken link = new LinkToken(); // Deploy a mock LINK token
        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinatorMock = new VRFCoordinatorV2Mock(baseFee, gasPriceLink);
        vm.stopBroadcast();
        return NetworkConfig({
            entranceFee : 0.01 ether,
            interval : 30,
            vrfCoordinator :address(vrfCoordinatorMock),
            gasLane :0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 0, //our script will create a subscriptionid and add it to the contract
            callbackGasLimit : 500000, //500,000 gas!
            link: address(link),
            deployerKey: ANVIL_PRIVATE_KEY
        });
    }
}