# Provable random Contracts

## About

This repository contains a set of smart contracts that implement a provable random number generator using Chainlink VRF (Verifiable Random Function). The contracts are designed to be used in decentralized applications (dApps) that require secure and verifiable random numbers.

## What we want it to do

1.  the user can enter buy paying fee for a ticket
    1.  the ticket fee are going to the winner who wins
2.  after X time , the lottery will autmatically draw a winner
    1. this will be done programtically
3.  Using the Chainlink VRF & Chainlink Automation
    1. chainlink vrf - randomness
    2. chainlink automation - time based triggered

////////////////////////////////////////////////////////////
//the vrf contract is used to get a random number
its a subscription based service
subscription works like this:
// 1. you create a subscription
// 2. you fund the subscription with LINK tokens
// 3. you add the VRF coordinator as a consumer(raffle contract) of the subscription
// 4. you request a random number from the VRF coordinator ............
