pragma solidity ^0.8.17;

// sheep, wolves 會越來越肥

contract PoolGame {
    address public owner;

    uint8 public winner;
    address[] public sheep;
    address[] public wolves;
    uint public sheepPoolBalance;
    uint public wolfPoolBalance;

    mapping(address => uint) public sheepBalance;
    mapping(address => uint) public wolfBalance;
    mapping(address => uint) public reward;

    uint public endTime;

    event Withdrawal(address indexed recipient, uint256 amount);
    event Deposit(address indexed depositor, uint8 group, uint256 amount);
    event WithdrawalReward(address indexed recipient, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function joinSheepPool() public payable {
        require(msg.value > 0, "You must deposit some ETH.");
        // if not in sheep list, added sender
        if (sheepBalance[msg.sender] == 0) {
            sheep.push(msg.sender);
        }

        // updated sender(sheep) balance
        sheepBalance[msg.sender] += msg.value;
        uint sheepPoolBalanceBefore = sheepPoolBalance;
        sheepPoolBalance += msg.value;

        // if this cause sheep pool > wolf pool, update endTime, update winner status
        if (
            sheepPoolBalanceBefore <= wolfPoolBalance &&
            sheepPoolBalance > wolfPoolBalance
        ) {
            _updateEndTime();
            winner = 1;
        }

        emit Deposit(msg.sender, 1, msg.value);
    }

    function joinWolfPool() public payable {
        require(msg.value > 0, "You must deposit some ETH.");
        // if not in wolf list, added sender
        if (wolfBalance[msg.sender] == 0) {
            wolves.push(msg.sender);
        }

        // updated sender(wolf) balance (wolf have 3 weight bonus)
        wolfBalance[msg.sender] += msg.value * 3;
        uint wolfPoolBalanceBefore = wolfPoolBalance;
        wolfPoolBalance += msg.value * 3;

        // if this cause wolf pool > sheep pool, update endTime, update winner status
        if (
            wolfPoolBalanceBefore <= sheepPoolBalance &&
            wolfPoolBalance > sheepPoolBalance
        ) {
            _updateEndTime();
            winner = 2;
        }

        emit Deposit(msg.sender, 2, msg.value);
    }

    function leaveSheepPool(uint amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(amount <= sheepBalance[msg.sender], "Insufficient balance");

        sheepBalance[msg.sender] -= amount;
        uint sheepPoolBalanceBefore = sheepPoolBalance;
        sheepPoolBalance -= amount;

        if (
            sheepPoolBalanceBefore >= wolfPoolBalance &&
            sheepPoolBalance < wolfPoolBalance
        ) {
            _updateEndTime();
            winner = 2;
        }

        // Transfer the amount to the recipient's address
        payable(msg.sender).transfer(amount);

        emit Withdrawal(msg.sender, amount);
    }

    function leaveWolfPool(uint amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(amount <= wolfBalance[msg.sender], "Insufficient balance");

        wolfBalance[msg.sender] -= amount * 3;
        uint wolfPoolBalanceBefore = wolfPoolBalance;
        sheepPoolBalance -= amount * 3;

        if (
            wolfPoolBalanceBefore >= sheepPoolBalance &&
            wolfPoolBalance < sheepPoolBalance
        ) {
            _updateEndTime();
            winner = 1;
        }

        // Transfer the amount to the recipient's address
        payable(msg.sender).transfer(amount);

        emit Withdrawal(msg.sender, amount);
    }

    function getPrize() public returns (uint) {
        require(block.timestamp >= endTime, "Game is still in progress.");
        require(winner != 0, "There is no winner yet.");

        // farmingReward
        uint farmingReward;

        // check status
        if (wolves.length == 0) {
            winner = 3; // contract win
        } else if (wolves.length == 1) {
            winner = 2; // wolf win
        }

        if (winner == 1) {
            // call sheep win prize
            _updateSheepReward(farmingReward);
        } else if (winner == 2) {
            // call wolf win prize
            _updateWolfReward(farmingReward);
        }

        // transfer prize
        _updateEndTime(); // update to new game

        return winner;
    }

    function _updateSheepReward(uint farmingReward) internal {
        address[] memory sheepWinner = sheep;
        uint sheepTotalBalance = sheepPoolBalance;

        for (uint256 i = 0; i < sheepWinner.length; i++) {
            reward[sheepWinner[i]] +=
                (sheepBalance[sheepWinner[i]] / sheepTotalBalance) *
                farmingReward;
        }
    }

    function _updateWolfReward(uint farmingReward) internal {
        address[] memory wolvesWinner = wolves;
        address wolfWinner;
        uint winnerBalance;

        for (uint256 i = 0; i < wolvesWinner.length; i++) {
            if (wolfBalance[wolvesWinner[i]] > winnerBalance) {
                wolfWinner = wolvesWinner[i];
                winnerBalance = wolfBalance[wolvesWinner[i]];
            }
            reward[wolfWinner] += farmingReward;
        }
    }

    function _updateEndTime() internal {
        endTime = block.timestamp + 7 days;
    }

    function claim(uint amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(amount <= reward[msg.sender], "Insufficient reward balance");

        reward[msg.sender] -= amount;

        // Transfer the amount to the recipient's address
        payable(msg.sender).transfer(amount);

        emit WithdrawalReward(msg.sender, amount);
    }
}
