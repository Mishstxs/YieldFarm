# STX Yield Farm

A decentralized yield farming protocol built on the Stacks blockchain that allows users to stake STX tokens and earn rewards over time.

## Overview

STX Yield Farm is a simple but effective DeFi protocol that enables users to:
- Stake STX tokens to earn passive rewards
- Claim accumulated rewards at any time
- Unstake their tokens with accumulated rewards
- Participate in decentralized liquidity mining

## Features

- **Stake STX**: Lock your STX tokens in the contract to start earning rewards
- **Flexible Rewards**: Earn rewards based on blocks passed and configurable reward rates
- **Claim Anytime**: Claim your earned rewards without unstaking your principal
- **Unstake**: Withdraw your staked tokens along with any pending rewards
- **Admin Controls**: Contract owner can adjust reward rates and manage contract status

## Smart Contract Functions

### Public Functions

- `stake(amount)` - Stake STX tokens to start earning rewards
- `unstake(amount)` - Unstake tokens and claim pending rewards
- `claim-rewards()` - Claim accumulated rewards without unstaking
- `withdraw-rewards(amount)` - Withdraw claimed rewards from the contract

### Read-Only Functions

- `get-user-stake(user)` - Get user's staking information
- `get-user-rewards(user)` - Get user's available rewards
- `get-total-staked()` - Get total STX staked in the contract
- `calculate-pending-rewards(user)` - Calculate pending rewards for a user

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Basic understanding of Clarity smart contracts

### Installation

1. Clone this repository
2. Navigate to the project directory
3. Run `clarinet check` to verify the contract
4. Run `clarinet test` to execute tests

### Usage

1. **Stake STX**: Call the `stake` function with the amount you want to stake
2. **Earn Rewards**: Rewards accumulate automatically based on blocks passed
3. **Claim Rewards**: Use `claim-rewards` to add pending rewards to your balance
4. **Withdraw**: Use `withdraw-rewards` to transfer rewards to your wallet
5. **Unstake**: Use `unstake` to withdraw your staked tokens

## Reward Mechanism

- Rewards are calculated based on the number of blocks passed since last claim
- Default reward rate is 1% per block (configurable by contract owner)
- Rewards are distributed proportionally to staked amounts

## Security

- Contract includes owner-only functions for administrative control
- Input validation for all public functions
- Safe arithmetic operations to prevent overflow/underflow
- Emergency pause functionality

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## License

This project is licensed under the MIT License.