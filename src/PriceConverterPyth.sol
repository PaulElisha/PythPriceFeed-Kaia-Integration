// SPDX-License-Identifier: MIT
// 1. Pragma
pragma solidity ^0.8.19;

import "@pythnetwork/IPyth.sol";
import "@pythnetwork/PythStructs.sol";

library PriceConverterPyth {
    function getPrice(
        bytes32 priceFeedId,
        IPyth pythFeed,
        bytes[] calldata priceUpdate
    ) internal returns (uint256 price) {
        IPyth pyth = pythFeed;
        uint fee = pyth.getUpdateFee(priceUpdate);
        pyth.updatePriceFeeds{value: fee}(priceUpdate);

        // Read the current price from a price feed.
        // Each price feed (e.g., ETH/USD) is identified by a price feed ID.
        // The complete list of feed IDs is available at https://pyth.network/developers/price-feed-ids
        // bytes32 priceFeedId = 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace; // ETH/USD
        PythStructs.Price memory NewPrice = pyth.getPrice(priceFeedId);
        // PythStructs.Price memory NewPrice = pyth.getPriceUnsafe(feedId);
        price = (uint256(uint64(NewPrice.price) * 10 ** 10));
    }

    function getConversionRate(
        uint256 klayAmount,
        bytes32 priceFeedId,
        IPyth pythFeed,
        bytes[] calldata priceUpdate
    ) internal returns (uint256 klayAmountInUsd) {
        uint256 klayPrice = getPrice(priceFeedId, pythFeed, priceUpdate);
        klayAmountInUsd = (klayPrice * klayAmount) / 1e18;
    }
}
