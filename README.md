# Foundry Smart Contract Lottery

This repository contains a provably fair, decentralized lottery smart contract system built with [Foundry](https://book.getfoundry.sh/) and powered by [Chainlink VRF](https://docs.chain.link/vrf/v2/introduction/) for randomness and [Chainlink Automation](https://docs.chain.link/chainlink-automation/introduction/) for automated execution.

## Features

- **Decentralized Lottery:** Users can enter the lottery by paying a ticket fee.
- **Automated Draws:** The lottery automatically selects a winner at set intervals using Chainlink Automation.
- **Provable Randomness:** Winner selection is powered by Chainlink VRF, ensuring fairness and transparency.
- **Self-Funding:** All ticket fees are pooled and awarded to the winner.

## How It Works

1. **Enter Lottery:** Users enter by sending the required ticket fee to the contract.
2. **Automated Draw:** After a predefined time interval, Chainlink Automation triggers the winner selection.
3. **Random Winner:** The contract requests a random number from Chainlink VRF and selects a winner.
4. **Payout:** The winner receives the entire pool of ticket fees.

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed
- [Node.js](https://nodejs.org/) (for scripting/deployment)
- [Chainlink VRF subscription](https://docs.chain.link/vrf/v2/subscription/)
- [Ethereum wallet](https://metamask.io/) with testnet/mainnet funds

## Setup

1. **Clone the repository:**
    ```shell
    git clone https://github.com/yourusername/Foundry-Smart-Contract_Lottery25.git
    cd Foundry-Smart-Contract_Lottery25
    ```

2. **Install dependencies:**
    ```shell
    forge install
    ```

3. **Configure environment variables:**
    - Copy `.env.example` to `.env` and fill in your RPC URL, private key, and Chainlink details.

## Usage

### Build Contracts

```shell
forge build
```

### Run Tests

```shell
forge test
```

### Format Code

```shell
forge fmt
```

### Gas Snapshots

```shell
forge snapshot
```

### Local Node

```shell
anvil
```

### Deploy

Update the deployment script and run:
```shell
forge script script/Lottery.s.sol:LotteryScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Interact with Contracts

```shell
cast <subcommand>
```

## Chainlink VRF & Automation Setup

1. **Create a Chainlink VRF subscription** and fund it with LINK tokens.
2. **Add your deployed contract as a consumer** to the subscription.
3. **Configure Chainlink Automation** to trigger the lottery draw at your desired interval.

## Documentation

- [Foundry Book](https://book.getfoundry.sh/)
- [Chainlink VRF Docs](https://docs.chain.link/vrf/v2/introduction/)
- [Chainlink Automation Docs](https://docs.chain.link/chainlink-automation/introduction/)
