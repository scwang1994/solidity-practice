// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
 
/*
TodoList Contract (Own Version)

idea: 一個只能自己用的 TodoList 合約

function setting: 與 TodoList 相同

other setting: 
    * 與 TodoList 相同
    * 需加上一個 modifier 來限制只有 Contract Owner 可以使用

hint:
    * 此合約基本與 TodoList 相同，僅所有函數應只能由 Owner 調用
    * 加入 Ownable Contract，在所有函數調用前確認是否為 Owner

question:
    * 如果連 tasks 都不想讓別人知道有什麼，該如何處理？
*/

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract TodoList is Ownable {
    event NewTask(uint taskId, string name, bool completed);
    event UpdateTask(uint taskId, bool completed);

    struct Task {
        string name;
        bool completed;
    }

    // question: 如果不想被別人看到 tasks 裡面有什麼，要怎麼控制？
    Task[] public tasks; 

    // goal: 新增 task
    // add modifier onlyOwner
    function create(string memory _name) public onlyOwner {
        tasks.push(Task(_name, false));
        uint id = tasks.length - 1;

        // emit, 讓 front-end 接到新增 task
        emit NewTask(id, _name, false);
    }

    // goal: 更新 task 狀態
    // add modifier onlyOwner
    function update(uint _taskId, bool _completed) public onlyOwner {
        tasks[_taskId].completed = _completed;

        // emit, 讓 front-end 接到更新 task 狀態
        emit UpdateTask(_taskId, _completed);
    }

    // goal: 確認 task 與完成狀態
    // hint: 用 view 不用 pure 是因為會使用到 global variable
    // add modifier onlyOwner
    function get(uint _taskId) public onlyOwner view returns (string memory name, bool completed) {
        return (tasks[_taskId].name, tasks[_taskId].completed);
    }

    // goal: 刪除合約
    // add modifier onlyOwner
    function kill() external onlyOwner {
        selfdestruct(payable(msg.sender));
    }
}

