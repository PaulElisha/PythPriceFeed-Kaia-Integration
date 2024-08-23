// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../test/mocks/MockPyth.sol";
import "../src/Constants.sol";

error NetworkConfig__NoConfig();

contract NetworkConfig is Constants, Script {
    struct Config {
        address pythFeedAddress;
        bytes32 priceFeedId;
    }

    Config public anvilConfig;

    mapping(uint256 chainId => Config) public configs;

    constructor() {
        configs[TESTNET_CONFIG] = getTestnetConfig();
        configs[MAINNET_CONFIG] = getMainnetConfig();
        configs[ANVIL_CONFIG] = getOrCreateAnvilConfig();
    }

    function getConfigByChainId(
        uint256 chainId
    ) public view returns (Config memory) {
        if (
            block.chainid == chainId &&
            configs[chainId].pythFeedAddress != address(0)
        ) {
            return configs[chainId];
        } else if (block.chainid == chainId) {
            return configs[chainId];
        } else {
            return configs[chainId];
        }
    }

    function getConfig() public view returns (Config memory) {
        return getConfigByChainId(block.chainid);
    }

    function getTestnetConfig() public pure returns (Config memory) {
        Config memory testnetConfig = Config({
            pythFeedAddress: 0x2880aB155794e7179c9eE2e38200202908C17B43,
            priceFeedId: 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace
        });
        return testnetConfig;
    }

    function getMainnetConfig() public pure returns (Config memory) {
        Config memory mainnetConfig = Config({
            pythFeedAddress: 0x2880aB155794e7179c9eE2e38200202908C17B43,
            priceFeedId: 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace
        });
        return mainnetConfig;
    }

    function getOrCreateAnvilConfig() public returns (Config memory) {
        if (anvilConfig.pythFeedAddress != address(0)) {
            return anvilConfig;
        }

        vm.startBroadcast();
        MockPyth mockPyth = new MockPyth(
            VALID_TIME_PERIOD,
            SINGLE_UPDATE_FEE_IN_WEI
        );
        vm.stopBroadcast();

        anvilConfig = Config({
            pythFeedAddress: address(mockPyth),
            priceFeedId: 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace
        });

        console.log(address(mockPyth));

        return anvilConfig;
    }
}
