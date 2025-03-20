// SPDX-License-Identifier: MIT

//Solidity
pragma solidity 0.8.28;

// Contract

contract CryptoInterestBank {
    // Variables
    uint256 public maxBalance;
    address public admin;
    bool public contractPaused = false;
    uint256 public annualInterestRate; // base 10000 (e.g. 1000 = 10%)
    uint256 public minBankBalance;

    struct UserData {
        uint256 balance;
        uint256 lastDepositTimestamp;
    }

    mapping(address => UserData) public users;

    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Unauthorized");
        _;
    }

    modifier NotPaused() {
        require(!contractPaused, "Contract is paused");
        _;
    }

    // Events
    event DepositEth(address user_, uint256 amount_);
    event WithdrawEth(address user_, uint256 amount_);
    event InterestPaid(address user_, uint256 interestAmount_);
    event PauseStatus(bool paused_);
    event InterestRateUpdated(uint256 newRate_);
    event MinBankBalanceUpdated(uint256 newMinBankBalance_);

    // Constructor
    constructor(
        uint256 maxBalance_,
        address admin_,
        uint256 interestRate_,
        uint256 minBankBalance_
    ) {
        maxBalance = maxBalance_;
        admin = admin_;
        contractPaused = false;
        annualInterestRate = interestRate_;
        minBankBalance = minBankBalance_;
    }

    // Deposit Ether
    function deposit() external payable NotPaused {
        require(
            users[msg.sender].balance + msg.value <= maxBalance,
            "Max balance exceeded"
        );

        uint256 interest = calculateInterest(msg.sender);
        if (interest > 0) {
            claimInterest();
        }

        users[msg.sender].balance += msg.value;
        users[msg.sender].lastDepositTimestamp = block.timestamp;
        emit DepositEth(msg.sender, msg.value);
    }

    // Withdraw Ether
    function withdraw(uint256 amount) external NotPaused {
        require(amount <= users[msg.sender].balance, "Insufficient balance");
        require(
            address(this).balance >= minBankBalance,
            "Bank balance below minimum limit"
        );
        // Calcular el interés acumulado antes de realizar el retiro
        uint256 interest = calculateInterest(msg.sender);
        if (interest > 0) {
            claimInterest();
        }
        users[msg.sender].balance -= amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdraw failed");
        emit WithdrawEth(msg.sender, amount);
    }

    // Claim interest
    function claimInterest() public NotPaused {
        uint256 interest = calculateInterest(msg.sender);
        require(interest > 0, "No interest available");
        users[msg.sender].balance += interest;
        users[msg.sender].lastDepositTimestamp = block.timestamp;
        (bool success, ) = msg.sender.call{value: interest}("");
        require(success, "Claim failed");
        emit InterestPaid(msg.sender, interest);
    }

    // Calculate interest
    function calculateInterest(address user) private view returns (uint256) {
        if (users[user].balance > 0) {
            uint256 timeElapsed = block.timestamp -
                users[user].lastDepositTimestamp;
            return
                (users[user].balance * annualInterestRate * timeElapsed) /
                (365 days * 10000);
        }
        return 0;
    }

    // Modify maxBalance
    function modifyMaxBalance(uint256 newMaxBalance) external onlyAdmin {
        maxBalance = newMaxBalance;
    }

    // Modify contractPaused
    function pauseContract(bool contractPaused_) external onlyAdmin {
        contractPaused = contractPaused_;
        emit PauseStatus(contractPaused_);
    }

    // Update annual interest rate
    function updateInterestRate(uint256 newRate_) external onlyAdmin {
        require(newRate_ < 10000, "Interest Rate must be under 100%");
        annualInterestRate = newRate_;
        emit InterestRateUpdated(newRate_);
    }

    // Update minimum bank balance
    function updateMinBankBalance(uint256 newMinBalance) external onlyAdmin {
        minBankBalance = newMinBalance;
        emit MinBankBalanceUpdated(newMinBalance);
    }

    // Get bank balance
    function getBankBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Get user balance
    function getMyAvailableBalance() external view returns (uint256) {
        return users[msg.sender].balance;
    }
}
