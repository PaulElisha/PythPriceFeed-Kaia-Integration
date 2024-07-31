// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/FundMe.sol";
import "../script/NetworkConfig.s.sol";
import "./CreatePriceUpdateData.s.sol";

contract DeployFundMe is Script {
    function deployFundMe()
        public
        returns (FundMe, NetworkConfig, CreatePriceUpdateData)
    {
        CreatePriceUpdateData createPriceUpdateData = new CreatePriceUpdateData();
        NetworkConfig networkConfig = new NetworkConfig();
        NetworkConfig.Config memory config = networkConfig.getConfig();

        address pythFeedAddress = config.pythFeedAddress;
        bytes32 pythPriceFeedId = config.priceFeedId;

        vm.startBroadcast();
        FundMe fundMe = new FundMe(pythFeedAddress, pythPriceFeedId);
        vm.stopBroadcast();

        return (fundMe, networkConfig, createPriceUpdateData);
    }

    function run()
        public
        returns (FundMe, NetworkConfig, CreatePriceUpdateData)
    {
        return deployFundMe();
    }
}
