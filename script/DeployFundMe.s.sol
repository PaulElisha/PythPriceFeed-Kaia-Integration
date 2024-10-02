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

        bytes[] memory updateData = new bytes[](1);
        updateData[
            0
        ] = "0x3078303100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006400000000000000000000000000000000000000000000000000000000000001f4fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000640000000000000000000000000000000000000000000000000000000000000190fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff80000000000000000000000000000000000000000000000000000000000000001";

        vm.startBroadcast();
        FundMe fundMe = new FundMe(pythFeedAddress, pythPriceFeedId);
        fundMe.fund(updateData);
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
