//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Test,console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract RaffleTest is Test {

    /*Events */
    event EnteredRaffle(address indexed player);

    Raffle raffle;
    HelperConfig helperConfig;
    address public PLAYER = makeAddr("player"); // makeAddr creates a new address for testing purposes and we have put player in makeaddr to make it more readable
    uint256 public constant STARTING_BALANCE = 10 ether; // This is the starting balance for the player

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;
    address link;

    function setUp()public {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.run();
        (
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit,
            link,
        ) = helperConfig.activeNetworkConfig();
        vm.deal(PLAYER, STARTING_BALANCE); // Give the player some ether to play with
    }

    function testRaffleInitialisationState () public view{
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testRaffleRevertsWhenNotEnoughEthSent() public {
        vm.startPrank(PLAYER);
        vm.expectRevert(Raffle.Raffle__NotEnoughEthSent.selector);
        raffle.enterRaffle(); // This should revert because we are not sending enough ETH
        vm.stopPrank();
    }

    function testRaffleRecordsPlayersWhenTheyEnter() public {
        vm.startPrank(PLAYER);
        raffle.enterRaffle{value: entranceFee}(); // Player enters the raffle with the required entrance fee
        address playerRecorded = raffle.getPlayer(0); // Get the list of players
        assertEq(playerRecorded, PLAYER); // Check if the player is recorded in the raffle
        vm.stopPrank();
    }
    function testEmitsEventOnEntrance() public {
        vm.startPrank(PLAYER);
        vm.expectEmit(true,false,false,false,address(raffle));
        emit EnteredRaffle(PLAYER);
        raffle.enterRaffle{value: entranceFee}(); // Player enters the raffle with the required entrance fee
        vm.stopPrank();
    }

    function testCantEnterRaffleWhileCalculating() public {
        vm.startPrank(PLAYER);
        raffle.enterRaffle{value: entranceFee}(); // Player enters the raffle with the required entrance fee
        vm.warp(block.timestamp + interval + 1); // Move the time forward to trigger the raffle calculation
        vm.roll(block.number + 1); // Move to the next block
        raffle.performUpKeep(""); // This will trigger the calculation of the winner
        vm.stopPrank();
        vm.startPrank(PLAYER);
        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector); // Expect the revert when trying to enter the raffle while it's calculating
        raffle.enterRaffle{value: entranceFee}(); // Player tries to enter the raffle again
        vm.stopPrank();   
    }
}
