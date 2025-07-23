// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FundMe {
    mapping (address => uint256) public founderToAmount;
    uint256 MINIMUM_VALUE = 1*10**18; //Wei
    function fund() external payable {
        require(msg.value >= MINIMUM_VALUE, "Send more ETH!");
        founderToAmount[msg.sender] = msg.value;
    }
}
