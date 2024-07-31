// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "foundry-devops/src/DevOpsTools.sol";
import "../src/FundMe.sol";
import "../script/CreatePriceUpdateData.s.sol";

error Interactions__MostRecentlyDeployedIsAddressZero();

contract Interactions is Script {
    CreatePriceUpdateData createPriceUpdateData = new CreatePriceUpdateData();
    uint256 public constant SEND_VALUE = 1 ether;

    function FundMeInteractions()
        public
        returns (bytes memory priceUpdateData)
    {
        address mostRecentlyDeployed = getMostRecentlyDeployedAddress();

        if (mostRecentlyDeployed == address(0))
            revert Interactions__MostRecentlyDeployedIsAddressZero();

        priceUpdateData = createPriceUpdateData.createPriceUpdateDataConfig();

        bytes[] memory updateData = new bytes[](1);
        updateData[0] = priceUpdateData;
        console.log("Price update data prepared");

        vm.startBroadcast();
        FundMe(mostRecentlyDeployed).fund{value: SEND_VALUE}(updateData);
        console.log("Fund function called successfully");
        vm.stopBroadcast();
        console.log("Funded fundMe with %s", SEND_VALUE);

        return priceUpdateData;
    }

    function getMostRecentlyDeployedAddress()
        public
        view
        returns (address mostRecentlyDeployed)
    {
        mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
    }

    function run() external {
        FundMeInteractions();
    }
}
