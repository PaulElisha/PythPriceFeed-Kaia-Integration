// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../test/mocks/MockPyth.sol";
import "@pythnetwork/PythStructs.sol";
import "../script/NetworkConfig.s.sol";
import "../src/Constants.sol";
import "./DeployFundMe.s.sol";

error CreatePriceUpdateData__InvalidPriceFeedId();
error CreatePriceUpdateData__PriceFeedIdDoesNotExist();
error CreatePriceUpdateData__InvalidMockAddress();

contract CreatePriceUpdateData is Script, Constants {
    function run() public returns (bytes memory) {
        return createPriceUpdateDataConfig();
    }

    function createPriceUpdateDataConfig()
        public
        returns (bytes memory priceUpdateData)
    {
        NetworkConfig networkConfig = new NetworkConfig();
        bytes32 id = networkConfig.getConfig().priceFeedId;
        address pythAddress = networkConfig.getConfig().pythFeedAddress;

        priceUpdateData = createPriceUpdataData(id, pythAddress);
    }

    function createPriceUpdataData(
        bytes32 id,
        address pythAddress
    ) public view returns (bytes memory priceFeedUpdateData) {
        if (id == hex"") {
            revert CreatePriceUpdateData__InvalidPriceFeedId();
        }

        if (pythAddress == address(0)) {
            revert CreatePriceUpdateData__InvalidMockAddress();
        }

        MockPyth mockPyth = MockPyth(pythAddress);
        console.log(pythAddress);

        if (!mockPyth.priceFeedExists(id)) {
            revert CreatePriceUpdateData__PriceFeedIdDoesNotExist();
        }

        priceFeedUpdateData = mockPyth.createPriceFeedUpdateData(
            id,
            PRICE,
            CONF,
            EXPO,
            EMA_PRICE,
            EMA_CONF,
            PUBLISH_TIME
        );

        /** Test MockPyth works */
        uint validTime = mockPyth.getValidTimePeriod();
        console.log(validTime);

        // PythStructs.PriceFeed memory priceFeed = mockPyth.queryPriceFeed(id);
        // console.log(priceFeed);
    }

    function setPriceData(
        bytes32 id
    ) public view returns (PythStructs.PriceFeed memory) {
        PythStructs.Price memory price = PythStructs.Price(
            PRICE,
            CONF,
            EXPO,
            PUBLISH_TIME
        );

        PythStructs.PriceFeed memory priceData = PythStructs.PriceFeed(
            id,
            price,
            price
        );

        return priceData;
    }
}
