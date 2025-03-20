// License
// SPDX-License-Identifier: MIT
// Solidity version
pragma solidity 0.8.28;

//Contract
import "forge-std/Test.sol";
import "../src/CryptoInterestBank.sol";

contract CryptoInterestBankTest is Test {
    CryptoInterestBank bank;
    address public admin = vm.addr(1);
    address public user1 = vm.addr(2);
    address public user2 = vm.addr(3);

    uint256 public maxBalance = 100 ether;
    uint256 public annualInterestRate = 1000; // 10%
    uint256 public minBankBalance = 10 ether;

    function setUp() public {
        // initialize contract
        bank = new CryptoInterestBank(maxBalance, admin, annualInterestRate, minBankBalance);

        // Fund user 1 and 2 with Ether
        vm.deal(user1, 200 ether);
        vm.deal(user2, 200 ether);
    }

    // Unit testing
    // Deposit Ether Testing
    function testInitialDeposits() public {
        uint256 firstDepositValue = 50 ether;
        uint256 SecondDepositValue = 20 ether;
        uint256 bankBalance = address(bank).balance;

        //First user deposits ether
        vm.prank(user1);
        bank.deposit{value: firstDepositValue}();
        (uint256 FirstUserBalance,) = bank.users(user1);
        assert(FirstUserBalance == firstDepositValue);
        assert(bank.getBankBalance() == bankBalance + firstDepositValue);

        //second user deposits ether
        bankBalance = address(bank).balance;

        vm.prank(user2);
        bank.deposit{value: SecondDepositValue}();
        (uint256 SecondUserBalance,) = bank.users(user2);
        assert(SecondUserBalance == SecondDepositValue);
        assert(bank.getBankBalance() == bankBalance + SecondDepositValue);
    }

    // Deposit exceeds max balance test
    function testDepositExceedsMaxBalance() public {
        uint256 depositValue = 105 ether;
        vm.prank(user1);
        vm.expectRevert("Max balance exceeded");
        bank.deposit{value: depositValue}();
    }

    // DepositWithInterest Test

    function testDepositWithInterest() public {
        uint256 firstDepositValue = 20 ether;
        uint256 secondDepositValue = 10 ether;
        uint256 bankBalance = address(bank).balance;
        uint32 simulatedDays = 650 days;
        //First deposit ether
        vm.startPrank(user1);
        bank.deposit{value: firstDepositValue}();

        //Simulate time
        vm.warp(block.timestamp + simulatedDays);
        (uint256 balanceBeforeSecondDeposit,) = bank.users(user1);

        //Second deposit with interest

        bank.deposit{value: secondDepositValue}();
        (uint256 UserFinalBalance,) = bank.users(user1);

        //expected interest
        uint256 expectedInterest = (firstDepositValue * annualInterestRate * simulatedDays) / (365 days * 10000);
        //expected balance
        uint256 expectedBalanceAfter = balanceBeforeSecondDeposit + secondDepositValue + expectedInterest;

        bankBalance = address(bank).balance;

        //Check final balance
        assert((UserFinalBalance == expectedBalanceAfter) && (expectedInterest != 0));

        //Check Bank Balance
        assert(bankBalance == firstDepositValue + secondDepositValue - expectedInterest);
        vm.stopPrank();
    }

    // Withdraw Ether
    function testWithdraw() public {
        uint256 firstDepositValue = 20 ether;
        uint256 firstWithdraw = 10 ether;
        uint256 bankBalance;
        vm.startPrank(user1);
        bank.deposit{value: firstDepositValue}();
        bank.withdraw(firstWithdraw);

        bankBalance = address(bank).balance;
        (uint256 UserFinalBalance,) = bank.users(user1);

        assert((bankBalance == firstDepositValue - firstWithdraw) && (UserFinalBalance == firstWithdraw));

        vm.stopPrank();
    }

    // Withdraw Ether with Interest
    function testWithdrawWithInterest() public {
        uint256 firstDepositValue = 20 ether;
        uint256 firstWithdraw = 10 ether;
        uint256 bankBalance;
        uint32 simulatedDays = 30 days;

        vm.startPrank(user1);
        bank.deposit{value: firstDepositValue}();
        // Simulate time
        vm.warp(block.timestamp + simulatedDays);

        bank.withdraw(firstWithdraw);

        bankBalance = address(bank).balance;
        (uint256 UserFinalBalance,) = bank.users(user1);

        //expected interest
        uint256 expectedInterest = (firstDepositValue * annualInterestRate * simulatedDays) / (365 days * 10000);
        //expected balance
        uint256 expectedBalanceAfter = firstWithdraw + expectedInterest;

        //Check final balance
        assert((UserFinalBalance == expectedBalanceAfter) && (expectedInterest != 0));

        //Check Bank Balance
        assert(bankBalance == firstDepositValue - firstWithdraw - expectedInterest);

        vm.stopPrank();
    }

    // Withdraw exceeds user balance
    function testWithdrawExceedsBalance() public {
        uint256 firstDepositValue = 20 ether;
        uint256 firstWithdraw = 21 ether;
        vm.startPrank(user1);
        bank.deposit{value: firstDepositValue}();
        vm.expectRevert();
        bank.withdraw(firstWithdraw);
        vm.stopPrank();
    }

    // Withdraw when bank balance is below minimum
    function testWithdrawBelowMinBankBalance() public {
        uint256 firstDepositValue = 1 ether;
        uint256 secondDepositValue = 4 ether;
        uint256 withdrawAmount = 3 ether;

        vm.prank(user1);
        bank.deposit{value: firstDepositValue}();

        vm.startPrank(user2);
        bank.deposit{value: secondDepositValue}();
        vm.expectRevert();
        bank.withdraw(withdrawAmount);
        vm.stopPrank();
    }

    // Claim interest
    function testClaimInterest() public {
        uint256 firstDepositValue = 1 ether;
        uint32 daysSimulated = 365 days;
        uint256 bankBalance;
        uint256 expectedInterest;

        vm.startPrank(user1);
        bank.deposit{value: firstDepositValue}();

        // Simulate time passing (30 days)
        vm.warp(block.timestamp + daysSimulated);
        bank.claimInterest();

        expectedInterest = (firstDepositValue * annualInterestRate * daysSimulated) / (365 days * 10000);
        bankBalance = address(bank).balance;
        assert(bankBalance == firstDepositValue - expectedInterest);
    }

    // Claim interest with no balance
    function testClaimInterestNoBalance() public {
        vm.startPrank(user1);
        vm.expectRevert();
        bank.claimInterest();
        vm.stopPrank();
    }

    // Update max balance (admin only)
    function testUpdateMaxBalance() public {
        uint256 newMaxBalance = 200 ether;
        vm.startPrank(admin);
        bank.modifyMaxBalance(newMaxBalance);
        assert(bank.maxBalance() == newMaxBalance);
        vm.stopPrank();
    }

    // Update max balance (non-admin)
    function testUpdateMaxBalanceNonAdmin() public {
        uint256 newMaxBalance = 200 ether;
        vm.startPrank(user1);
        vm.expectRevert();
        bank.modifyMaxBalance(newMaxBalance);
        vm.stopPrank();
    }

    // Pause contract (admin only)
    function testPauseContract() public {
        vm.startPrank(admin);
        bank.pauseContract(true);
        assertTrue(bank.contractPaused());
        vm.stopPrank();
    }

    //  Pause contract (non-admin)
    function testPauseContractNonAdmin() public {
        vm.startPrank(user1);
        vm.expectRevert();
        bank.pauseContract(true);
        vm.stopPrank();
    }

    // Update interest (admin only)
    function testUpdateInterest() public {
        uint256 newInterest = 5000;
        vm.startPrank(admin);
        bank.updateInterestRate(newInterest);
        assert(bank.annualInterestRate() == newInterest);
    }

    //  Update interest rate (non-admin)
    function testUpdateInterestNonAdmin() public {
        uint256 newInterest = 5000;
        vm.startPrank(user1);
        vm.expectRevert();
        bank.updateInterestRate(newInterest);
    }

    //  Update interest rate above 100%
    function testUpdateInterestAbove100() public {
        uint256 newInterest = 10001;
        vm.startPrank(admin);
        vm.expectRevert();
        bank.updateInterestRate(newInterest);
    }

    //  Update min bank balance (admin only)
    function testUpdateMinBankBalance() public {
        uint256 newMinBalance = 20 ether;
        vm.startPrank(admin);
        bank.updateMinBankBalance(newMinBalance);
        assert(bank.minBankBalance() == newMinBalance);
    }

    //  Update min bank balance (non-admin)
    function testUpdateMinBankBalanceNonAdmin() public {
        uint256 newMinBalance = 20 ether;
        vm.startPrank(user1);
        vm.expectRevert();
        bank.updateMinBankBalance(newMinBalance);
    }

    //  Get bank balance
    function testGetBankBalance() public {
        uint256 depositValue = 50 ether;
        vm.prank(user1);
        bank.deposit{value: depositValue}();

        assert(bank.getBankBalance() == depositValue);
    }

    //  Get user balance
    function testGetUserBalance() public {
        uint256 depositValue = 50 ether;
        vm.startPrank(user1);
        bank.deposit{value: depositValue}();

        assert(bank.getMyAvailableBalance() == depositValue);
        vm.stopPrank();
    }

    // Fuzz Testing

    // Deposit
    function testFuzzDeposit(uint256 depositAmount_) public {
        vm.assume(depositAmount_ > 0 && depositAmount_ <= maxBalance);

        uint256 initialBankBalance = address(bank).balance;

        vm.startPrank(user1);
        bank.deposit{value: depositAmount_}();

        (uint256 userBalance,) = bank.users(user1);

        assert(userBalance == depositAmount_);
        assert(bank.getBankBalance() == initialBankBalance + depositAmount_);

        vm.stopPrank();
    }

    // Withdraw

    function testFuzzWithdraw(uint256 depositAmount_) public {
        uint256 minDeposit = minBankBalance;
        uint256 withdrawAmount = 10 ether;

        //Range using assume
        vm.assume(depositAmount_ >= minDeposit && depositAmount_ <= maxBalance);
        vm.assume(withdrawAmount <= depositAmount_);

        vm.startPrank(user1);
        bank.deposit{value: depositAmount_}();
        bank.withdraw(withdrawAmount);

        (uint256 userBalance,) = bank.users(user1);
        assert(userBalance == depositAmount_ - withdrawAmount);
        assert(address(bank).balance == depositAmount_ - withdrawAmount);

        vm.stopPrank();
    }

    // Claim
    function testFuzzInterestCalculation(uint256 depositAmount_, uint256 elapsedTime_) public {
        // Adjust Range using bound
        depositAmount_ = bound(depositAmount_, 1 ether, maxBalance);
        elapsedTime_ = bound(elapsedTime_, 1 days, 5 * 365 days);

        vm.startPrank(user1);
        bank.deposit{value: depositAmount_}();

        vm.warp(block.timestamp + elapsedTime_);

        uint256 expectedInterest = (depositAmount_ * annualInterestRate * elapsedTime_) / (365 days * 10000);

        bank.claimInterest();

        (uint256 userBalance,) = bank.users(user1);
        assert(userBalance >= depositAmount_ + expectedInterest);
        vm.stopPrank();
    }

    // Max Balance
    function testFuzzModifyMaxBalance(uint256 newMaxBalance_) public {
        vm.assume(newMaxBalance_ > 0 && newMaxBalance_ <= 1000 ether);

        vm.startPrank(admin);
        bank.modifyMaxBalance(newMaxBalance_);
        assert(bank.maxBalance() == newMaxBalance_);
        vm.stopPrank();
    }

    // Max Balance non-admin
    function testFuzzModifyMaxBalanceNonAdmin(uint256 newMaxBalance_) public {
        vm.assume(newMaxBalance_ > 0 && newMaxBalance_ <= 1000 ether);

        vm.startPrank(user1);
        vm.expectRevert();
        bank.modifyMaxBalance(newMaxBalance_);
        vm.stopPrank();
    }
}
