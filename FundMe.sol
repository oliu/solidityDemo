// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/*
1.收款函数
2.记录投资人并且查看
3.在锁定期内，达到目标值，生产商可以提款
4.在锁定期内，没有达到目标值，投资人可以退款
*/
contract FundMe {
    mapping (address => uint256) public fundersToAmount;

    AggregatorV3Interface internal dataFeed;

    // uint256 MINIMUM_VALUE = 100*10**18; //100USD
    uint256 MINIMUM_VALUE = 1*10**18; //1USD
    // constant常量，别人不能改
    uint256 constant TARGET = 1000; // 1000USD

    address owner;
    // 开始时间
    uint256 deploymentTimestamp;
    // 锁定时间
    uint256 lockTime = 60; // 60秒



    constructor(uint256 _lockTime){
        // sepolia testnet
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        owner = msg.sender;
        deploymentTimestamp = block.timestamp;
        lockTime = _lockTime;
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

    function fund() external payable {
        require(convertEthToUsd(msg.value) >= MINIMUM_VALUE, "Send more ETH!");
        require(block.timestamp < deploymentTimestamp + lockTime, "window is closed" );
        fundersToAmount[msg.sender] = msg.value;
    }

    function getFund() external windowClose onlyOwner{
        uint256 balance = address(this).balance;
        require(convertEthToUsd(balance) >= TARGET, "Target is not reached");
        // require(msg.sender == owner, "this function can only be called by owner");
        // require(block.timestamp >= deploymentTimestamp + lockTime, "window is not closed" );
        // 3种转账方式
        // 1.transfer 纯转账 transfer ETH and revert if tx failed
        // payable(msg.sender).transfer(address(this).balance);
        // 2.send 纯转账 transfer ETH and return false if failed
        // bool success = payable(msg.sender).send(address(this).balance);
        // require(success, "tx failed");
        // 3.call 转账加调用一些逻辑  transfer ETH with data return value of function and bool
        bool success;
        (success, ) = payable(msg.sender).call{value: address(this).balance}("");

    }

    function transferOwnership(address newOwner) public onlyOwner{
        // require(msg.sender == owner, "This function can only be called by owner");
        owner = newOwner;
    }

    function refund() external windowClose {
        require(convertEthToUsd(address(this).balance) < TARGET, "Target is reached");
        require(fundersToAmount[msg.sender] != 0, "there is no fund for you");
        // require(block.timestamp >= deploymentTimestamp + lockTime, "window is closed" );
        bool success;
        (success, ) = payable(msg.sender).call{value: fundersToAmount[msg.sender]}("");
        require(success, "transfer tx failed");
        fundersToAmount[msg.sender] = 0;
    }
    // 修改器
    modifier windowClose() {
         require(block.timestamp >= deploymentTimestamp + lockTime, "window is closed" );
        //  表示应用该函数后再进行其它操作
         _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "This function can only be called by owner");
         _;
    }
}
