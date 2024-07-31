// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./PriceConverterPyth.sol";
import "@pythnetwork/IPyth.sol";
import "@pythnetwork/PythStructs.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverterPyth for uint256;

    address private immutable i_owner;
    bytes32 public immutable i_feedId;
    uint256 public constant MINIMUM_USD = 2 * 1e18;
    address[] private Funders;
    mapping(address => uint256) private addressToAmountFunded;
    IPyth public pyth;

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Caller is not the owner");

        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    constructor(address priceFeedAddress, bytes32 priceFeedId) {
        i_owner = msg.sender;
        pyth = IPyth(priceFeedAddress);
        i_feedId = priceFeedId;
    }

    function fund(bytes[] calldata priceUpdate) public payable {
        require(
            msg.value.getConversionRate(i_feedId, pyth, priceUpdate) >=
                MINIMUM_USD,
            "Didn't send enough ETH"
        );
        Funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        uint256 fundersLength = Funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex > fundersLength;
            funderIndex = funderIndex + 1
        ) {
            address funder = Funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        Funders = new address[](0);
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Call failed");
    }

    function getAddressToAmountFunded(
        address funder
    ) public view returns (uint256) {
        return addressToAmountFunded[funder];
    }

    function getFunder(uint index) public view returns (address) {
        return Funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }
}
