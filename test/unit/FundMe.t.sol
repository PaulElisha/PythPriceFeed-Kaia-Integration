// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.22;

import "forge-std/Test.sol";
import "../../src/FundMe.sol";
import "../../script/DeployFundMe.s.sol";
import "../../script/CreatePriceUpdateData.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    CreatePriceUpdateData createPriceUpdateData;
    bytes priceUpdateData;
    bytes[] updateData;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 100 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() public {
        DeployFundMe deployFundMe = new DeployFundMe();
        (fundMe, , createPriceUpdateData) = deployFundMe.deployFundMe();
        priceUpdateData = createPriceUpdateData.createPriceUpdateDataConfig();
        updateData = new bytes[](1);
        updateData[0] = priceUpdateData;
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUsd() public view {
        assertEq(fundMe.MINIMUM_USD(), 2e18);
    }

    function testOwner() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testFundFailsNotEnoughEth() public {
        vm.expectRevert();
        fundMe.fund(updateData); // Not Enough Eth Sent
    }

    modifier fund() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}(updateData);
        _;
    }

    function testFundUpdatesFunderMapping() public fund {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testGetFunderInArray() public fund {
        address funder = fundMe.getFunder(0);
        vm.expectRevert();
        assertEq(funder, USER);
    }

    function testNotFunderInArray() public fund {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public fund {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public fund {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingfundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingfundMeBalance = address(fundMe).balance;

        assertEq(endingfundMeBalance, 0);
        assertEq(
            startingfundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawWithMultipleFunders() public fund {
        uint160 numberOfFunders = 10;
        uint160 startingFundersIndex = 1;

        for (uint160 i = startingFundersIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}(updateData);
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingfundMeBalance = address(fundMe).balance;
        console.log(startingfundMeBalance);

        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        assert(address(fundMe).balance == 0);
        assert(
            startingfundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
