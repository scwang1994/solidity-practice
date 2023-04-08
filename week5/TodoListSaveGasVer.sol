// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*
TodoList Contract (Save Gas Version)

idea: 以 TodoList 合約為基礎，改寫一個更省 gas 的版本
hint:
    * get() 使用 view 可以省 gas (不能改用 pure，雖然更省 gas 但有調用到 global variable)

TodoList 
    deploy gas: 917581
    create() gas: 83844
    update() gas: 55013
    get() gas: 34051
    kill() gas: 32605

SaveGasVer
    deploy gas: 917581
    create() gas: 83844
    update() gas: 55013
    get() gas: 0
    kill() gas: 32605

*/

contract TodoList {
    address public owner;
    Task[] public tasks;

    constructor() {
        owner = msg.sender;
    }

    event NewTask(uint taskId, string name, bool completed);
    event UpdateTask(uint taskId, bool completed);

    struct Task {
        string name;
        bool completed;
    }

    // goal: 新增 task
    // issue: list.push will not return the length of it anymore. 
    // solution: https://ethereum.stackexchange.com/questions/78634/solc-v0-6-0-typeerror-operator-not-compatible-with-types-tuple-and-int-con
    function create(string memory _name) external {
        tasks.push(Task(_name, false)); // list.push will not return the length of it anymore. 
        uint id = tasks.length - 1;

        // emit, 讓 front-end 接到新增 task
        emit NewTask(id, _name, false);
    }

    // goal: 更新 task 狀態
    function update(uint _taskId, bool _completed) external {
        tasks[_taskId].completed = _completed;

        // emit, 讓 front-end 接到更新 task 狀態
        emit UpdateTask(_taskId, _completed);
    }

    // goal: 確認 task 與完成狀態
    // hint: 用 view 不用 pure 是因為會使用到 global variable
    function get(uint _taskId) external view returns (string memory name, bool completed) {
        return (tasks[_taskId].name, tasks[_taskId].completed);
    }

    // goal: 刪除合約
    function kill() external {
        require(msg.sender == owner, "not contract owner");
        selfdestruct(payable(msg.sender));
    }
}