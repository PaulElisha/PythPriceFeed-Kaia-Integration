// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

abstract contract Constants {
    uint public VALID_TIME_PERIOD = block.timestamp + 2 days;
    uint public constant SINGLE_UPDATE_FEE_IN_WEI = 1 ether;

    uint256 public constant TESTNET_CONFIG = 1001;
    uint256 public constant MAINNET_CONFIG = 8217;
    uint256 public constant ANVIL_CONFIG = 31337;

    int64 public constant PRICE = 100;
    uint64 public constant CONF = 5000;
    int32 public constant EXPO = -8;
    int64 public constant EMA_PRICE = 100;
    uint64 public constant EMA_CONF = 4000;
    uint64 public PUBLISH_TIME = uint64(block.timestamp);
}
