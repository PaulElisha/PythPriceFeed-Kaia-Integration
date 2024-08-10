# PriceConverterPyth Library

## Overview

The `PriceConverterPyth` library is a Solidity library designed to convert token amounts on the Klaytn network to USD by leveraging the Pyth Network's price feeds. This utility allows developers to easily fetch real-time price data for KLAY/USD and convert token values into USD within their smart contracts.

## Key Features

- **Fetch KLAY/USD Price:** The library fetches the latest KLAY/USD exchange rate from the Pyth Network.
- **Convert KLAY to USD:** Converts a given amount of KLAY into its equivalent USD value using the fetched exchange rate.
- **Integration with Pyth Network:** The library is integrated with the Pyth Network, a trusted source for real-time, decentralized price feeds.

## Prerequisites

- Solidity version `^0.8.19`
- The Pyth Network's price feed contracts available on the Klaytn network.

## Library Functions

### 1. `getPrice`

```solidity
function getPrice(
    bytes32 priceFeedId,
    IPyth pythFeed,
    bytes[] calldata priceUpdate
) internal returns (uint256 price)
```

- **Description:** Fetches the current KLAY/USD price from the Pyth Network's price feed.
- **Parameters:**
  - `priceFeedId`: The unique identifier of the price feed (e.g., KLAY/USD feed ID).
  - `pythFeed`: The address of the Pyth Network's price feed contract.
  - `priceUpdate`: An array of price update data that is used to update the on-chain price feed.
- **Returns:** The current KLAY/USD exchange rate, scaled to 18 decimal places.

- **Process:**
  1. The function first submits a price update to the Pyth contract using the provided `priceUpdate` data, paying the necessary fee.
  2. It then retrieves the latest KLAY/USD price using the `priceFeedId` and returns the price scaled to 18 decimal places.

- **Important Notes:**
  - Ensure the price update is submitted before fetching the price. Failing to do so might result in outdated or incorrect data, leading to transaction failures.

### 2. `getConversionRate`

```solidity
function getConversionRate(
    uint256 klayAmount,
    bytes32 priceFeedId,
    IPyth pythFeed,
    bytes[] calldata priceUpdate
) internal returns (uint256 klayAmountInUsd)
```

- **Description:** Converts a specified amount of KLAY into its USD equivalent using the latest price data from the Pyth Network.
- **Parameters:**
  - `klayAmount`: The amount of KLAY to be converted to USD.
  - `priceFeedId`: The unique identifier of the price feed (e.g., KLAY/USD feed ID).
  - `pythFeed`: The address of the Pyth Network's price feed contract.
  - `priceUpdate`: An array of price update data used to update the on-chain price feed.
- **Returns:** The equivalent USD value of the given KLAY amount.

- **Process:**
  1. The function first calls `getPrice()` to fetch the current KLAY/USD exchange rate.
  2. It then calculates the USD equivalent of the provided KLAY amount by multiplying the exchange rate with `klayAmount` and dividing by 1e18 (to account for the scaling factor).

## Example Usage

```solidity
import "./PriceConverterPyth.sol";

contract MyContract {
    using PriceConverterPyth for uint256;
    
    IPyth public pythFeed;
    bytes32 public priceFeedId;
    
    constructor(IPyth _pythFeed, bytes32 _priceFeedId) {
        pythFeed = _pythFeed;
        priceFeedId = _priceFeedId;
    }
    
    function convertKlayToUsd(uint256 klayAmount, bytes[] calldata priceUpdate) external returns (uint256) {
        return klayAmount.getConversionRate(priceFeedId, pythFeed, priceUpdate);
    }
}
```

## Conclusion

The `PriceConverterPyth` library provides a simple and effective way to interact with the Pyth Network's price feeds on the Klaytn blockchain. By using this library, developers can easily fetch real-time KLAY/USD prices and convert token amounts into USD, enabling more dynamic and responsive smart contract applications.




# CreatePriceUpdateData Solidity Contract

## Overview

This project contains the `CreatePriceUpdateData` contract, a utility for generating price feed update data using the Pyth Network's mock implementation (`MockPyth`). The contract is designed to create and validate price data updates on test networks, leveraging configuration data provided by a separate `NetworkConfig` contract.

The key purpose of this contract is to generate and simulate price feed updates, which can be used to test and develop applications that rely on Pyth Network price feeds.

## Key Components

### Imports
- **forge-std/Script.sol**: Used to create and execute scripts with Foundry, a popular Ethereum development framework.
- **MockPyth.sol**: A mock implementation of the Pyth Network's on-chain components, used for testing purposes.
- **PythStructs.sol**: Contains the struct definitions used by Pyth Network contracts.
- **NetworkConfig.s.sol**: Script that manages network-specific configuration, including price feed IDs and mock Pyth addresses.
- **Constants.sol**: Contains constant values used throughout the contract.

### Errors
- **CreatePriceUpdateData__InvalidPriceFeedId**: Thrown when the price feed ID provided is invalid or empty.
- **CreatePriceUpdateData__PriceFeedIdDoesNotExist**: Thrown when the specified price feed ID does not exist in the mock Pyth contract.
- **CreatePriceUpdateData__InvalidMockAddress**: Thrown when the mock Pyth address is invalid (e.g., an address of `0x0`).

### `CreatePriceUpdateData` Contract
This contract contains the following key functions:

1. **`run()`**: This is the main entry point for the script. It calls `createPriceUpdateDataConfig()` to generate the price update data.

2. **`createPriceUpdateDataConfig()`**: This function fetches the price feed ID and mock Pyth address from the `NetworkConfig` contract and passes them to `createPriceData()` to generate the price update data.

3. **`createPriceData()`**: This function:
   - Validates the provided price feed ID and mock Pyth address.
   - Checks if the specified price feed ID exists in the mock Pyth contract.
   - Uses the validated data to generate price feed update data using the `MockPyth.createPriceFeedUpdateData()` function.
   - Optionally tests the mock Pyth functionality, such as retrieving the valid time period.

4. **`setPriceData()`**: This function creates and returns a `PriceData` struct populated with the price data constants defined in the `Constants` contract.

### `PriceData` Struct
The `PriceData` struct represents the price data required to update a price feed:
- **`id`**: The unique identifier of the price feed.
- **`price`**: The current price of the asset.
- **`conf`**: The confidence interval for the price.
- **`expo`**: The exponent used to scale the price (e.g., -8 means the price is in 10^-8 units).
- **`emaPrice`**: The exponentially weighted moving average of the price.
- **`emaConf`**: The confidence interval for the EMA price.
- **`publishTime`**: The timestamp when the price data was published.

### Constants
- **`VALID_TIME_PERIOD`**: The period within which the price update is valid, set to 2 days from the current block timestamp.
- **`SINGLE_UPDATE_FEE_IN_WEI`**: The fee for a single price update, set to 0.01 ETH.
- **Price Data Constants**: Various constants related to the price data, such as `PRICE`, `CONF`, `EXPO`, `EMA_PRICE`, `EMA_CONF`, and `PUBLISH_TIME`.

## Usage

1. **Compilation**: Compile the contract using the Foundry toolchain.
   ```bash
   forge compile
   ```

2. **Execution**: Run the script to generate the price update data on a specific network.
   ```bash
   forge script script/CreatePriceUpdateData.s.sol:CreatePriceUpdateData -f <network>
   ```

   Replace `<network>` with your desired RPC URL or network name.

3. **Testing**: You can test the contract's functionality by interacting with the `MockPyth` contract and observing the price feed updates generated.

## Troubleshooting

- Ensure the `NetworkConfig` contract is properly configured for your test network, including correct price feed IDs and mock Pyth addresses.
- Verify that the `MockPyth` contract is deployed and contains the necessary price feeds before running the script.

## Conclusion

The `CreatePriceUpdateData` contract is a helpful tool for developers working with the Pyth Network, allowing them to simulate price feed updates in a controlled test environment. By leveraging mock contracts and network-specific configurations, developers can efficiently test and validate their applications that depend on Pyth's price feeds.


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
