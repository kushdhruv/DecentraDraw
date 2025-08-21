// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {VRFCoordinatorV2Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/VRFConsumerBaseV2.sol";
/**
 * @title A simple Raffle Smart contract
 * @author Dhruv 
 * @notice This contract allows users to enter a raffle by sending Ether.
 * @dev Implement Chainlink VRFv2.
 */

contract Raffle is VRFConsumerBaseV2 {

    error Raffle__NotEnoughEthSent(); // custom error
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();
    error Raffle__UpKeepNotNeeded(
        uint256 currentBalance,
        uint256 numPlayers,
        uint256 raffleState
    );

    /*Type Declarations*/
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private immutable i_entranceFee;
    //@Dev duration of lottery in seconds
    uint256 private immutable i_interval;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    address payable[] private s_players;
    uint256 private s_lastTimestamp;
    address private s_recentWinner;
    RaffleState private s_raffleState;

    /** Events */
    event EnteredRaffle(address indexed player);
    event WinnerPicked(address indexed winner);

    //as VRFConsumerBaseV2 is an abstract contract and contains a constructor, so.... we need to call the constructor of the parent contract
    constructor(uint256 entranceFee, uint256 interval, address vrfCoordinator, bytes32 gasLane, uint64 subscriptionId, uint32 callbackGasLimit) 
    VRFConsumerBaseV2(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_lastTimestamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle () external payable{
        if(s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }
        if(msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEthSent();
        }
        s_players.push(payable(msg.sender)); //payable is used to send ether to
        emit EnteredRaffle(msg.sender);
    }
    //1. Get a random number
    //2. use the random number to pick random winner
    //3. be automatically called after a certain time
    //4. send the winner the entire balance of the contract


    /**
     * @dev this is the function that Chainlink Automation will call to check if the upkeep(pickwinner) is needed.
     * The following conditions must be met:
     * 1. The time interval has passed since the last time the winner was picked.
     * 2. The raffle is in the OPEN state.
     * 3. There are players in the raffle.
     * 4. The contract has a balance greater than zero. 
     */
    function checkUpKeep(bytes memory /*checkData*/) public view returns (bool upKeepNeeded, bytes memory /*performData*/)
    {
        bool hasTimePassed =(block.timestamp - s_lastTimestamp >= i_interval);
        bool isOpen = (s_raffleState == RaffleState.OPEN);
        bool hasPlayers = (s_players.length > 0);
        bool hasBalance = (address(this).balance > 0);
        upKeepNeeded = (hasTimePassed && isOpen && hasPlayers && hasBalance);
        return (upKeepNeeded, "0x0"); //performData is not used in this case, so we return a dummy value "0x0"
    } 

    function performUpKeep(bytes memory /*performData*/)external{
        (bool upKeepNeeded, ) = checkUpKeep("");
        if(!upKeepNeeded) {
            revert Raffle__UpKeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }

        s_raffleState = RaffleState.CALCULATING;
         i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
    }

    function fulfillRandomWords(uint256 /*requestId*/ , uint256[] memory randomWords) internal override{
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner = winner;
        //Resetting everything to start a new raffle
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimestamp = block.timestamp;
        (bool success, ) = winner.call{value: address(this).balance}("");
        if(!success) {
            revert Raffle__TransferFailed();
        }
        emit WinnerPicked(winner);
    }

    /**Getters */
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
    function getRaffleState()external view returns (RaffleState) {
        return s_raffleState;
    }
    function getPlayer(uint256 index) external view returns (address) {
        return s_players[index];
    }
    function getPlayersLength() external view returns (uint256) {
        return s_players.length;
    }
    function getRecentWinner() external view returns (address) {
        return s_recentWinner;
    }
}