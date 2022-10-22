// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Deposit is Ownable {
    address loanContract;

    address[] private depositors;

    uint256 lockedFunds;
    
    constructor(address _loanContract, address[] memory _depositors) {
        loanContract = _loanContract;

        delete depositors;
        depositors = _depositors;
    }

    function setDepositors(address[] calldata _users) public onlyOwner {
        delete depositors;
        depositors = _users;
    }

    function isDepositor(address _user) public view returns (bool) {
        uint256 depositorsLength = depositors.length;
        for (uint256 i = 0; i < depositorsLength;) {
            if (depositors[i] == _user) {
                return true;
            }
            unchecked { ++i; }
        }
        return false;
    }

    function lockFunds(uint256 _amount) external {
        require(address(msg.sender) == loanContract, "Only the loan contract can lock funds");
        lockedFunds += _amount;
    }

    function withdrawFunds(uint256 _amount) external {
        require(isDepositor(msg.sender) || owner() == msg.sender, "Only depositors and owner can withdraw funds");
        require(lockedFunds >= _amount, "Not enough locked funds");

        payable(msg.sender).transfer(_amount);

        lockedFunds -= _amount;
    }
}