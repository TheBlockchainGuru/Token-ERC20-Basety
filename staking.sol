// SPDX-License-Identifier: UNLICENSED

/*
░██████╗████████╗░█████╗░██╗░░██╗██╗███╗░░██╗░██████╗░  ░█████╗░░█████╗░███╗░░██╗████████╗██████╗░░█████╗░░█████╗░████████╗
██╔════╝╚══██╔══╝██╔══██╗██║░██╔╝██║████╗░██║██╔════╝░  ██╔══██╗██╔══██╗████╗░██║╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝
╚█████╗░░░░██║░░░███████║█████═╝░██║██╔██╗██║██║░░██╗░  ██║░░╚═╝██║░░██║██╔██╗██║░░░██║░░░██████╔╝███████║██║░░╚═╝░░░██║░░░
░╚═══██╗░░░██║░░░██╔══██║██╔═██╗░██║██║╚████║██║░░╚██╗  ██║░░██╗██║░░██║██║╚████║░░░██║░░░██╔══██╗██╔══██║██║░░██╗░░░██║░░░
██████╔╝░░░██║░░░██║░░██║██║░╚██╗██║██║░╚███║╚██████╔╝  ╚█████╔╝╚█████╔╝██║░╚███║░░░██║░░░██║░░██║██║░░██║╚█████╔╝░░░██║░░░
╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝╚═╝░░╚══╝░╚═════╝░  ░╚════╝░░╚════╝░╚═╝░░╚══╝░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚═╝░╚════╝░░░░╚═╝░░░
*/







pragma solidity ^0.6.0;


import "./basety.sol";

contract TokenFarm {

    using SafeMath for uint256;
    string  public name = "Basety Staking";
    Basety  public basety;
    address public owner;
    uint256 public stakeTime = 14400; 
    uint256 public bigRate = 6;
    uint256 public smallRate = 2;
    mapping(address=>uint256) public stakingBalance;
    mapping(address=>bool) public hasStaked;
    mapping(address=>bool) public isStaking;
    mapping(address => uint256) public stakedTime;
    address[] public staker;

    constructor (Basety _basety) public{
  
        basety = _basety;
        owner = msg.sender; // address of the owner of the contract
    }

    /// @param _amount The amount of the tokens you want to stake.

    function stakeToken(uint256 _amount) public {
        // check, amount should be greater than zero. There should be some tokens to be staked.
        require(_amount>0,"amount need to be more than 0");         
        // this refers to the instance of the contract where the call is made (you can have multiple instances of the same contract).
        // address(this) refers to the address of the instance of the contract where the call is being made.
        // msg. sender refers to the address where the contract is being called from.
        // @param _amount, the amount of tokens you want to stake .

        basety.transferFrom(msg.sender, address(this), _amount); 
        // The balance of the owner of the contract, after staking the coins.

        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        if(!hasStaked[msg.sender]){
            staker.push(msg.sender);
        }
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
        stakedTime[msg.sender] = block.timestamp;
    }
       
    function unstakeToken() public {

        require(isStaking[msg.sender] == true,"You have nothing to unstake.");
        require(stakedTime[msg.sender] + stakeTime < block.timestamp, "you have to unstake token after 4 hours from stake time");
        uint256 rewardAmount;
        uint256 balance = stakingBalance[msg.sender];

        if( balance > 10000){
            rewardAmount = balance.div(100);
            rewardAmount = rewardAmount.mul(bigRate);
        } else  {
            rewardAmount = balance.div(100);
            rewardAmount = rewardAmount.mul(smallRate);
        }
        stakingBalance[msg.sender] = 0;
        basety.transfer(msg.sender, balance + rewardAmount);
        isStaking[msg.sender] = false;


    }

    function setTime (uint256 _time) public {
        require(msg.sender == owner, "you are not a owner");
        stakeTime = _time;
    }

    function ownerTransfer (address _newOwner) public {
        require(msg.sender == owner, "you are not a owner");
        owner = _newOwner;
    }

    function setBigRate (uint256 _rate) public {
        require(msg.sender == owner, "you are not a owner");
        bigRate = _rate;
    }

    function setSmallRate (uint256 _rate) public {
        require(msg.sender == owner, "you are not a owner");
        smallRate = _rate;
    }
}