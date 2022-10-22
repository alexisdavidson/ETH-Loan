// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Deposit is Ownable {
    address guarantyOracleContract;
    address private depositor;

    uint256 lockedFunds;
    
    constructor(address _guarantyOracleContract, address _depositor) {
        guarantyOracleContract = _guarantyOracleContract;
        depositor = _depositor;
    }

    function setDepositors(address _user) public onlyOwner {
        depositor = _user;
    }

    function lockFunds(uint256 _amount) external {
        require(address(msg.sender) == guarantyOracleContract, "Only guarantyOracleContract can lock funds");
        lockedFunds += _amount;
    }

    function withdrawFunds(uint256 _amount) external {
        require(depositor == msg.sender || owner() == msg.sender, "Only depositors and owner can withdraw funds");
        require(lockedFunds >= _amount, "Not enough locked funds");

        payable(msg.sender).transfer(_amount);

        lockedFunds -= _amount;
    }
}