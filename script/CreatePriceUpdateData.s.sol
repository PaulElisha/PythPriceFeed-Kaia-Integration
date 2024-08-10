// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../test/mocks/MockPyth.sol";
import "@pythnetwork/PythStructs.sol";
import "../script/NetworkConfig.s.sol";
import "../src/Constants.sol";

error CreatePriceUpdateData__InvalidPriceFeedId();
error CreatePriceUpdateData__PriceFeedIdDoesNotExist();
error CreatePriceUpdateData__InvalidMockAddress();

contract CreatePriceUpdateData is Constants, Script {
    struct PriceData {
        bytes32 id;
        int64 price;
        uint64 conf;
        int32 expo;
        int64 emaPrice;
        uint64 emaConf;
        uint64 publishTime;
    }

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

        priceUpdateData = createPriceData(id, pythAddress);
    }

    function createPriceData(
        bytes32 id,
        address pythAddress
    ) public returns (bytes memory priceFeedUpdateData) {
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

        PriceData memory priceData = setPriceData(id);

        vm.startBroadcast();
        priceFeedUpdateData = mockPyth.createPriceFeedUpdateData(
            priceData.id,
            priceData.price,
            priceData.conf,
            priceData.expo,
            priceData.emaPrice,
            priceData.emaConf,
            priceData.publishTime
        );
        vm.stopBroadcast();

        /** Test MockPyth works */
        uint validTime = mockPyth.getValidTimePeriod();
        console.log(validTime);

        // PythStructs.PriceFeed memory priceFeed = mockPyth.queryPriceFeed(id);
        // console.log(priceFeed);
    }

    function setPriceData(bytes32 id) public view returns (PriceData memory) {
        PriceData memory priceData = PriceData({
            id: id,
            price: PRICE,
            conf: CONF,
            expo: EXPO,
            emaPrice: EMA_PRICE,
            emaConf: EMA_CONF,
            publishTime: PUBLISH_TIME
        });

        return priceData;
    }
}
