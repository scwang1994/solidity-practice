// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
 
/*
TodoList Contract (Open Version)

idea: 一個大家都能用的 TodoList 合約

function setting: 與 TodoList 相同

other setting: 
    * 與 TodoList 相同
    * 需 mapping 記錄 task 屬於誰
    * 須記錄一個 owner 有幾個 tasks
    * 需加上一個 modifier 來限制只有 task owner 可以更新狀態和查看其 task

hint:
    * 與 Owner Version 相似，有使用者的限制。不同之處在於改為每個人都可以使用該合約
    * 故 Open Version create() 應所有人都能使用，沒有權限限制
    * update() && get() 為 task owner 才能使用
    * kill() 應只有合約擁有者才能調用
*/

contract TodoList {
    event NewTask(uint taskId, string name, bool completed);
    event UpdateTask(uint taskId, bool completed);

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    struct Task {
        string name;
        bool completed;
    }

    Task[] public tasks;
    
    mapping (uint => address) public taskToOwner; // task 屬於誰
    mapping (address => uint) ownerTasksCount; // 每個人有的 tasks 數量

    /**
    * @dev Throws if called by any account other than the task owner.
    */
    modifier onlyTaskOwner(uint _taskId) {
        require(msg.sender == taskToOwner[_taskId]);
        _;
    }

    // goal: 新增 task
    function create(string memory _name) public {
        tasks.push(Task(_name, false)); 
        uint id = tasks.length - 1;
        // 記錄 task id 屬於誰
        taskToOwner[id] = msg.sender;
        // 該 owner task 數量 + 1
        ownerTasksCount[msg.sender]++;
        // emit, 讓 front-end 接到新增 task
        emit NewTask(id, _name, false);
    }

    // goal: 更新 task 狀態
    function update(uint _taskId, bool _completed) public onlyTaskOwner(_taskId) {
        tasks[_taskId].completed = _completed;
        // emit, 讓 front-end 接到更新 task 狀態
        emit UpdateTask(_taskId, _completed);
    }

    // goal: 確認 task 與完成狀態
    // hint: 用 view 不用 pure 是因為會使用到 global variable
    function get(uint _taskId) public onlyTaskOwner(_taskId) view returns (string memory name, bool completed) {
        return (tasks[_taskId].name, tasks[_taskId].completed);
    }

    // goal: 刪除合約
    function kill() external {
        require(msg.sender == owner, "not contract owner");
        selfdestruct(payable(msg.sender));
    }
}

