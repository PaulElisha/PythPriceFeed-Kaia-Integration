// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../test/mocks/MockPyth.sol";
import "@pythnetwork/PythStructs.sol";
import "../script/NetworkConfig.s.sol";
import "../src/Constants.sol";

error CreatePriceUpdateData__InvalidPriceFeedId();
error CreatePriceUpdateData__PriceFeedIDDoesNotExist();

contract CreatePriceUpdateData is Constants, Script {
    struct PriceData {
        int64 price;
        uint64 conf;
        int32 expo;
        int64 emaPrice;
        uint64 emaConf;
        uint64 publishTime;
    }

    function run() public {
        createPriceUpdateDataConfig();
    }

    function createPriceUpdateDataConfig()
        public
        returns (bytes memory priceUpdateData)
    {
        NetworkConfig networkConfig = new NetworkConfig();
        bytes32 Id = networkConfig.getConfig().priceFeedId;

        priceUpdateData = createPriceData(Id);
    }

    function createPriceData(
        bytes32 id
    ) public returns (bytes memory priceFeedUpdateData) {
        MockPyth mockPyth = new MockPyth(
            VALID_TIME_PERIOD,
            SINGLE_UPDATE_FEE_IN_WEI
        );

        if (!mockPyth.priceFeedExists(id))
            revert CreatePriceUpdateData__PriceFeedIDDoesNotExist();

        if (id == hex"") {
            revert CreatePriceUpdateData__InvalidPriceFeedId();
        }

        PriceData memory priceData = setPriceData();

        vm.startBroadcast();
        priceFeedUpdateData = mockPyth.createPriceFeedUpdateData(
            id,
            priceData.price,
            priceData.conf,
            priceData.expo,
            priceData.emaPrice,
            priceData.emaConf,
            priceData.publishTime
        );

        /** Test MockPyth works */
        uint validTime = mockPyth.getValidTimePeriod();
        console.log(validTime);
        vm.stopBroadcast();
    }

    function setPriceData() public view returns (PriceData memory) {
        PriceData memory priceData = PriceData({
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
