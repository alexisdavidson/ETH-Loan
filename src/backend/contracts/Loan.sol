// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Loan is Ownable {
    address depositContract;

    string constant bankAccount = "";
    uint256 constant requiredCollateralRatio = 120;
    string constant contractId = "0a0bc10a-2733-4998-8566-989cd3666a81";
    uint256 constant loaPrincipal = 400000;
    uint256 constant interestRate = 15;
    uint256 constant decimal = 100;
    address constant rampAddress = 0xD71E736a7eF7a9564528D41c5c656c46c18a2AEd;
    
    uint256 totalAmountWithdrawn;
    uint256 totalCommitedCapital;
    uint256 totalAvailableCapital;
    uint256 totalRepayedCapital;
    uint256 futureValue;
    
    struct CommitedDepositor {
        address _address;
        uint256 _commitValue;
    }
    CommitedDepositor[] commitedDepositors;

    struct DepositorProRata {
        address _address;
        uint256 _proRataShare;
    }

    constructor(address _depositContract) {
        depositContract = _depositContract;
    }

    function checkColateral(uint256 _requestAmount) view public returns(bool) {
        uint256 _value = _requestAmount * requiredCollateralRatio / decimal - totalAmountWithdrawn;
        return _value > calculateFutureValue(_requestAmount);
    }

    function requestLoanWithdrawal(uint256 _requestAmount) public {
        if (checkColateral(_requestAmount)) {
            if (_requestAmount <= totalAvailableCapital) {
                payable(rampAddress).transfer(_requestAmount);

                totalAmountWithdrawn += _requestAmount;
                totalAvailableCapital -= _requestAmount;
                futureValue += calculateFutureValue(_requestAmount);
            }
        }
    }

    function newCommit() payable public {
        require(msg.sender == depositContract, "Only deposit contract can call this function");
        commitedDepositors.push(CommitedDepositor(msg.sender, msg.value));
        totalCommitedCapital += msg.value;
        totalAvailableCapital += msg.value;
    }

    function repayment() payable public {
        require(msg.sender == rampAddress, "Only callable from the ramp address");
        totalRepayedCapital += msg.value;
    }

    function calculateProRata() view public returns(DepositorProRata[] memory) {
        uint256 _depositorsLength = commitedDepositors.length;
        DepositorProRata[] memory depositorProRatas = new DepositorProRata[](_depositorsLength);
        for(uint256 i = 0; i < _depositorsLength; i++) {
            depositorProRatas[i] = DepositorProRata(commitedDepositors[i]._address, commitedDepositors[i]._commitValue / totalCommitedCapital);
        }

        return depositorProRatas;
    }

    function repayDepository(uint256 _amortizationAmount) payable public {
        DepositorProRata[] memory depositorProRatas = calculateProRata();

        uint256 _depositorsLength = depositorProRatas.length;
        for(uint256 i = 0; i < _depositorsLength; i++) {
            payable(depositorProRatas[i]._address).transfer(depositorProRatas[i]._proRataShare * _amortizationAmount);
        }

        totalAvailableCapital -= msg.value;
        totalRepayedCapital += msg.value;
    }

    function calculateFutureValue(uint256 _withdrawalAmount) pure public returns(uint256) {
        return _withdrawalAmount * interestRate / decimal;
    }
}