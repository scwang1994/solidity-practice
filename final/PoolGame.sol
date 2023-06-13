pragma solidity ^0.8.17;

contract PoolGame {
    address public owner;

    uint8 public winner;
    address[] public sheep;
    address[] public wolves;
    uint public sheepPoolBalance;
    uint public wolfPoolBalance;

    mapping(address => uint) public sheepBalance;
    mapping(address => uint) public wolfBalance;

    uint public endTime;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");
        _;
    }

    function joinSheepPool() public payable {
        require(msg.value > 0, "You must deposit some ETH.");

        if (sheepBalance[msg.sender] == 0) {
            sheep.push(msg.sender);
        }

        sheepBalance[msg.sender] += msg.value;
        uint sheepPoolBalanceBefore = sheepPoolBalance;
        sheepPoolBalance += msg.value;

        if (
            sheepPoolBalanceBefore <= wolfPoolBalance &&
            sheepPoolBalance > wolfPoolBalance
        ) {
            updateEndTime();
            winner = 1;
        }
    }

    function joinWolfPool() public payable {
        require(msg.value > 0, "You must deposit some ETH.");

        if (wolfBalance[msg.sender] == 0) {
            wolves.push(msg.sender);
        }

        wolfBalance[msg.sender] += msg.value * 3;
        uint wolfPoolBalanceBefore = wolfPoolBalance;
        wolfPoolBalance += msg.value * 3;

        if (
            wolfPoolBalanceBefore <= sheepPoolBalance &&
            wolfPoolBalance > sheepPoolBalance
        ) {
            updateEndTime();
            winner = 2;
        }
    }

    function updateEndTime() internal {
        endTime = block.timestamp + 7 days;
    }

    function getPrize() public returns (uint) {
        require(block.timestamp >= endTime, "Game is still in progress.");
        require(winner != 0, "There is no winner yet.");

        if (wolves.length == 0) {
            winner = 3; // contract win
        } else if (wolves.length == 1) {
            winner = 2; // wolf win
        }

        return winner;
    }
}
