// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interaction.s.sol";

contract InteractionTest is Test {
    FundMe fundMe;

    address USER = makeAddr("USER");
    uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000 wei
    uint256 constant STARTING_FUND_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_FUND_BALANCE);
    }

    function testUserCanFundAndWithdrawInteractions() public {
        uint256 preUserBalance = address(USER).balance;
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 postUserBalance = address(USER).balance;
        uint256 postOwnerBalance = address(fundMe.getOwner()).balance;

        assert(address(fundMe).balance == 0);
        assertEq(postUserBalance + SEND_VALUE, preUserBalance);
        assertEq(postOwnerBalance, preOwnerBalance + SEND_VALUE);
    }
}