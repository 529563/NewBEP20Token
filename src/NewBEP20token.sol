// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

///////////////////
// imports
///////////////////

import {ERC20} from "./openzeppelin-contracts/ERC20.sol";
import {ERC20Permit} from "./openzeppelin-contracts/ERC20Permit.sol";
import {ReentrancyGuard} from "./openzeppelin-contracts/ReentrancyGuard.sol";
import {ECDSA} from "./openzeppelin-contracts/ECDSA.sol";

/*
 * @title NewBEP20token
 * @author Sanjay Sen
 */

contract NewBEP20token is ERC20, ERC20Permit, ReentrancyGuard {
    ///////////////////
    // Errors
    ///////////////////

    error NewBEP20token__ToomanyTransactionsInAShortTime();
    error NewBEP20token__TransferTooSoonPleaseWait();
    error NewBEP20token_TooManyTransactionsInAShortTime();

    ///////////////////
    // State Variables
    ///////////////////

    /*
     * @dev Constant MIN_TIME_BETWEEN_TRANSFERS defines the minimum time interval between consecutive transfer transactions.
     * This is implemented to prevent overly frequent transactions that might be triggered by automated programs or bots.
     * For example, if the value of MIN_TIME_BETWEEN_TRANSFERS is set to 3 minutes, a user won't be able to execute two transfer
     * transactions between the same accounts within less than the specified time interval, which helps prevent potential manipulations
     * or exploitation of the system.
     */

    uint256 public constant MIN_TIME_BETWEEN_TRANSFERS = 3 minutes;

    /*
     * @dev Mapping to track the last transaction block number for each address.
     */

    mapping(address => uint) public lastTransactionBlock;

    /*
     * @dev Mapping to track the last transaction time for each address.
     */

    mapping(address => uint) public lastTransactionTime;

    ///////////////////
    // constructor
    ///////////////////

    /*
     * @dev Contract constructor, sets the initial amount of tokens and registers them to the creator's address.
     */

    constructor(
        string memory name_,
        string memory symbol_
    ) payable ERC20(name_, symbol_) ERC20Permit(name_) {
        uint256 initialSupply = 200000000 * (10 ** uint256(decimals()));
        _mint(msg.sender, initialSupply);
    }

    ///////////////////
    // Modifiers
    ///////////////////

    /*
     * @dev Modifier to limit the number of transactions within a specified number of blocks.
     * @param minBlocks The minimum number of blocks between transactions.
     */

    // modifier throttleBlocks(uint minBlocks) {
    //     require(
    //         block.number - lastTransactionBlock[msg.sender] >= minBlocks,
    //         "Too many transactions in a short time."
    //     );
    //     _;
    //     lastTransactionBlock[msg.sender] = block.number;
    // }

    modifier throttleBlocks(uint minBlocks) {
        if (block.number - lastTransactionBlock[msg.sender] >= minBlocks) {
            revert NewBEP20token__ToomanyTransactionsInAShortTime();
        }
        _;
        lastTransactionBlock[msg.sender] = block.number;
    }

    /*
     * @dev Modifier timeLimit restricts the execution of a function based on the time elapsed since the last transaction from a specific address.
     * It ensures that a certain amount of time, defined by MIN_TIME_BETWEEN_TRANSFERS, has passed since the last transaction from the given address.
     * If the time condition is not met, the function execution is reverted with the error message "Transfer too soon, please wait."
     * This modifier is useful for preventing users from executing transactions too frequently, thus mitigating potential abuse or spamming of the system.
     */

    // modifier timeLimit(address from) {
    //     require(
    //         block.timestamp >=
    //             lastTransactionTime[from] + MIN_TIME_BETWEEN_TRANSFERS,
    //         "Transfer too soon, please wait."
    //     );
    //     _;
    // }

    modifier timeLimit(address from) {
        if (
            block.timestamp >=
            lastTransactionTime[from] + MIN_TIME_BETWEEN_TRANSFERS
        ) {
            revert NewBEP20token__TransferTooSoonPleaseWait();
        }
        _;
    }

    /*
     * @dev Modifier to limit the number of transactions within a specified amount of time in seconds.
     * @param minSeconds The minimum time in seconds between transactions.
     */

    // modifier throttleTime(uint minSeconds) {
    //     require(
    //         block.timestamp - lastTransactionTime[msg.sender] >= minSeconds,
    //         "Too many transactions in a short time."
    //     );
    //     _;
    //     lastTransactionTime[msg.sender] = block.timestamp;
    // }

    modifier throttleTime(uint minSeconds) {
        if (block.timestamp - lastTransactionTime[msg.sender] >= minSeconds) {
            revert NewBEP20token_TooManyTransactionsInAShortTime();
        }
        _;

        lastTransactionTime[msg.sender] = block.timestamp;
    }

    ///////////////////
    // Function
    ///////////////////

    /*
     * @dev Function transfer facilitates the transfer of tokens from the sender's address to the specified recipient.
     * It overrides the transfer function from the parent contract and adds the timeLimit modifier to restrict the frequency of transfers
     * from the sender's address based on the MIN_TIME_BETWEEN_TRANSFERS constant.
     * - The timeLimit modifier ensures that a certain amount of time has passed since the last transfer from the sender's address,
     * helping to prevent excessive transaction frequency.
     * - If the time limit requirement is met, the transfer is executed by calling the transfer function of the parent contract.
     * - The function returns a boolean indicating whether the transfer was successful or not.
     */

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override timeLimit(msg.sender) returns (bool) {
        return super.transfer(recipient, amount);
    }

    /*
     * @dev Function transferFrom allows a designated spender to transfer tokens from the sender's address to the specified recipient.
     * It overrides the transferFrom function from the parent contract and adds the timeLimit modifier to restrict the frequency of transfers
     * from the sender's address based on the MIN_TIME_BETWEEN_TRANSFERS constant.
     * - The timeLimit modifier ensures that a certain amount of time has passed since the last transfer from the sender's address,
     * helping to prevent excessive transaction frequency.
     * - If the time limit requirement is met, the transferFrom function of the parent contract is called to execute the transfer.
     * - The function returns a boolean indicating whether the transfer was successful or not.
     */

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override timeLimit(sender) returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }

    /*
     * @dev Function for secure token transfer, using modifiers for enhanced transaction security.
     * @param to The recipient's address.
     * @param amount The amount of tokens to transfer.
     */

    function secureTransfer(
        address to,
        uint256 amount
    ) public throttleBlocks(3) throttleTime(60) nonReentrant {
        _transfer(_msgSender(), to, amount);
    }
}
