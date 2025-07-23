// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


contract FundMe {
    mapping (address => uint256) public founderToAmount;

    AggregatorV3Interface internal dataFeed;

    uint256 MINIMUM_VALUE = 100*10**18; //100USD


    constructor(){
        // sepolia testnet
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

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
