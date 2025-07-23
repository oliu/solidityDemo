// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/*
1.收款函数
2.记录投资人并且查看
3.在锁定期内，达到目标值，生产商可以提款
4.在锁定期内，没有达到目标值，投资人可以退款
*/
// Wei Gwei=10^9Wei Finney=10^15 Ether=10^18
contract FundMe {
    mapping (address => uint256) public founderToAmount;

    AggregatorV3Interface internal dataFeed;

    uint256 MINIMUM_VALUE = 100*10**18; //100USD


    constructor(){
        // sepolia testnet
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }
 //payable 可以用于接收链上原生通证
    function fund() external payable {
        require(convertEthToUsd(msg.value) >= MINIMUM_VALUE, "Send more ETH!");
        founderToAmount[msg.sender] = msg.value;
    }
        
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function convertEthToUsd(uint256 ethAmount) internal view returns (uint256){
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        // (ETH amount) * (ETH price) = (ETH value)
        return ethAmount * ethPrice/(10**8);
        
    }
}
