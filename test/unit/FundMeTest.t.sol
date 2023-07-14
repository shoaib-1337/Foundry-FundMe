//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundme} from "../../script/DeployFundme.s.sol";

contract FundMeTest is Test {
    uint256 number = 0;
    FundMe fundme;
    address USER = makeAddr("USER");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BAL = 10 ether;
    uint256 public GAS_PRICE = 1;

    function setUp() external {
        //fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundme deployFundme = new DeployFundme();
        fundme = deployFundme.run();
        vm.deal(USER, STARTING_BAL);
    }

    function testMinimumDollar() public {
        //console.log(number);
        assertEq(fundme.MINIMUM_USD(), 5 * 10 ** 18);
        // test
    }

    function testOwnerIsMsgSender() public {
        address owner = fundme.getOwner();
        assertEq(owner, msg.sender);
    }

    function testPriceFeedVersion() public {
        uint256 version = fundme.getVersion();
        assertEq(version, 4);
    }

    function testFundNotEnoughETH() public {
        vm.expectRevert(); //NEXT LINE COULD REVERT
        fundme.fund();
    }

    function testFundUpdatesFundedDataStructures() public {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        uint256 fundedAmount = fundme.s_addressToAmountFunded(USER);
        assertEq(fundedAmount, SEND_VALUE);
    }

    function testAddFundersToArrayOfFunders() public {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        address funder = fundme.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();

        vm.expectRevert(); //NEXT LINE COULD REVERT
        vm.prank(USER);
        fundme.withdraw();
    }

    function testWtithdrawWithASingleFunder() public funded {
        //Arrange
        uint256 StartingOwnerBalance = fundme.getOwner().balance;
        uint256 StartingFundMeBalance = address(fundme).balance;

        //Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);
        //Assert
        uint256 EndingOwnerBalance = fundme.getOwner().balance;
        uint256 EndingFundMeBalance = address(fundme).balance;
        assertEq(EndingFundMeBalance, 0);
        assertEq(
            StartingFundMeBalance + StartingOwnerBalance,
            EndingOwnerBalance
        );
    }

    function testWithdrawWithMultipleFunder() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingOwnerIndex = 1;
        for (uint160 i = startingOwnerIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }

        //Arrange
        uint256 StartingOwnerBalance = fundme.getOwner().balance;
        uint256 StartingFundMeBalance = address(fundme).balance;
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        // uint256 EndingOwnerBalance = fundme.getOwner().balance;
        // uint256 EndingFundMeBalance = address(fundme).balance;
        //Assert
        assertEq(address(fundme).balance, 0);
        assertEq(
            StartingFundMeBalance + StartingOwnerBalance,
            fundme.getOwner().balance
        );
    }

    function testCheaperWithdraw() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingOwnerIndex = 1;
        for (uint160 i = startingOwnerIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }

        //Arrange
        uint256 StartingOwnerBalance = fundme.getOwner().balance;
        uint256 StartingFundMeBalance = address(fundme).balance;
        vm.prank(fundme.getOwner());
        fundme.CheaperWithdraw();
        // uint256 EndingOwnerBalance = fundme.getOwner().balance;
        // uint256 EndingFundMeBalance = address(fundme).balance;
        //Assert
        assertEq(address(fundme).balance, 0);
        assertEq(
            StartingFundMeBalance + StartingOwnerBalance,
            fundme.getOwner().balance
        );
    }
}
