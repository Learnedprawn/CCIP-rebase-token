## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
# CCIP-rebase-token
1. A protocol that allows user to deposit into a vault and in return, receiver rebase tokens that represent their underlying balance.
2. Rebase token -> balanceOf function is dynamic to show the changing to show the changing balance with time.
  - Balance increases linerly with time
  - mint tokens to our users every time they perform an action (minting, burning, transferring, or bridging)
3. Interest rate
  - Individually set interest rate for each user based on some global interest rate of the protocol at the time the user deposits into the vault.
  - This global interest rate can only decrease to incentivise/reward early adopters.