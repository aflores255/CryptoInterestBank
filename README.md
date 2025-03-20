# 🏦 CryptoInterestBank Smart Contract

## 📌 **Description**
The **CryptoInterestBank** is a Solidity smart contract that allows users to deposit and withdraw Ether while earning interest over time. The contract includes security features such as access control for administrative actions and a minimum bank balance requirement to ensure liquidity.

This contract was developed and tested using **Foundry**, a powerful framework for Solidity testing and development.

---

## 🚀 **Features**
| **Feature** | **Description** |
|------------|---------------|
| 💰 **Deposit** | Users can deposit Ether and start earning interest. |
| 💸 **Withdraw** | Users can withdraw their balance if the bank has sufficient funds. |
| 🏦 **Interest Accumulation** | Interest is calculated based on the deposit duration. |
| 🔄 **Claim Interest** | Users can claim their earned interest separately from their balance. |
| ⏸️ **Pause Contract** | The admin can pause the contract to prevent new deposits and withdrawals. |
| 🔐 **Admin Controls** | Admins can update interest rates, minimum balances, and the contract's status. |

---

## 📜 **Contract Details**

### 🔑 **Modifiers**
| **Modifier** | **Description** |
|-------------|----------------|
| **`onlyAdmin`** | Restricts access to administrative functions. |
| **`NotPaused`** | Ensures that the contract is not paused before executing a function. |

### 📡 **Events**
| **Event** | **Description** |
|-----------|----------------|
| **`DepositEth`** | Emitted when a user deposits Ether. |
| **`WithdrawEth`** | Emitted when a user withdraws Ether. |
| **`InterestPaid`** | Emitted when a user claims interest. |
| **`PauseStatus`** | Emitted when the contract is paused or resumed. |
| **`InterestRateUpdated`** | Emitted when the admin updates the interest rate. |
| **`MinBankBalanceUpdated`** | Emitted when the minimum bank balance is changed. |

### 🔧 **Contract Functions**

| **Function** | **Description** |
|------------|----------------|
| **`deposit()`** | Allows users to deposit Ether and updates their balance. |
| **`withdraw(uint256 amount)`** | Lets users withdraw funds, ensuring the bank has sufficient liquidity. |
| **`claimInterest()`** | Enables users to claim their accumulated interest. |
| **`calculateInterest(address user)`** | Computes the interest for a given user. |
| **`modifyMaxBalance(uint256 newMaxBalance)`** | Admin function to set a new maximum balance per user. |
| **`pauseContract(bool status)`** | Admin function to pause or resume the contract. |
| **`updateInterestRate(uint256 newRate)`** | Admin function to adjust the annual interest rate. |
| **`updateMinBankBalance(uint256 newMinBalance)`** | Admin function to change the minimum required balance for the bank. |
| **`getBankBalance()`** | Returns the total Ether balance of the contract. |
| **`getMyAvailableBalance()`** | Returns the available balance of the calling user. |

---

## 🧪 **Testing with Foundry**
The contract has been rigorously tested using Foundry. The **CryptoInterestBankTest.t.sol** file contains unit tests to verify the contract's functionality.

### ✅ **Implemented Tests**
| **Test** | **Description** |
|-----------|----------------|
| **`testInitialDeposits`** | Tests deposits from multiple users. |
| **`testDepositExceedsMaxBalance`** | Ensures deposits do not exceed the maximum limit. |
| **`testDepositWithInterest`** | Verifies interest accumulation over time. |
| **`testWithdraw`** | Tests the basic withdrawal functionality. |
| **`testWithdrawWithInterest`** | Ensures withdrawals include earned interest. |
| **`testWithdrawExceedsBalance`** | Prevents users from withdrawing more than they have. |
| **`testWithdrawBelowMinBankBalance`** | Ensures the bank retains a minimum balance. |
| **`testClaimInterest`** | Tests the interest claiming mechanism. |
| **`testClaimInterestNoBalance`** | Prevents interest claims when no balance exists. |
| **`testUpdateMaxBalance`** | Ensures only the admin can change the max balance. |
| **`testUpdateInterest`** | Verifies interest rate updates. |
| **`testUpdateMinBankBalance`** | Checks the minimum bank balance modification. |
| **`testPauseContract`** | Tests the ability to pause and resume the contract. |
| **`testFuzzDeposit`** | Uses fuzzing to test deposits with random values. |
| **`testFuzzWithdraw`** | Uses fuzzing to test withdrawals with random values. |

---

## 🛠️ **How to Use**

### 🔧 **Prerequisites**
- Install **Foundry**: [Installation Guide](https://book.getfoundry.sh/)

### 🚀 **Deployment Steps**
1. Clone the project repository from GitHub.
   ```sh
   git clone https://github.com/your-repo/CryptoInterestBank.git
   ```
2. Navigate to the project folder.
   ```sh
   cd CryptoInterestBank
   ```
3. Install dependencies.
   ```sh
   forge install
   ```
4. Run the tests.
   ```sh
   forge test
   ```
5. Deploy the contract on an Ethereum-compatible blockchain.

---

## 📄 **License**
This project is licensed under the **MIT License**. Feel free to use, improve it and make more tests! 🚀
