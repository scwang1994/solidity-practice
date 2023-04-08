// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*
TodoList Contract

idea: 一個 TodoList 合約，能讓使用者在上面記錄待辦事項與是否完成

function setting: 
    1. 要有 create()，可以新增 task
    2. 要有 update()，可以更新 task 狀態
    3. 要有 get()，可以確認 task 與完成狀態
    4. 要有 kill()，可以刪除此合約

other setting:
    * 狀態變化要能被前端取得，create() && update() 皆需要接 event
    * kill() 應只有合約擁有者才能調用

hint:
    * 此合約與 cryptozombies 相似，應可參考其寫法
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

    // goal: 新增 task
    // issue: list.push will not return the length of it anymore. 
    // solution: https://ethereum.stackexchange.com/questions/78634/solc-v0-6-0-typeerror-operator-not-compatible-with-types-tuple-and-int-con
    function create(string memory _name) public  {
        tasks.push(Task(_name, false)); // list.push will not return the length of it anymore. 
        uint id = tasks.length - 1;

        // emit, 讓 front-end 接到新增 task
        emit NewTask(id, _name, false);
    }

    // goal: 更新 task 狀態
    function update(uint _taskId, bool _completed) public {
        tasks[_taskId].completed = _completed;

        // emit, 讓 front-end 接到更新 task 狀態
        emit UpdateTask(_taskId, _completed);
    }

    // goal: 確認 task 與完成狀態
    // hint: 用 view 不用 pure 是因為會使用到 global variable
    function get(uint _taskId) public returns (string memory name, bool completed) {
        return (tasks[_taskId].name, tasks[_taskId].completed);
    }

    // goal: 刪除合約
    // issue: "selfdestruct" has been deprecated.
    // https://eips.ethereum.org/EIPS/eip-6049
    function kill() public  {
        require(msg.sender == owner, "not contract owner");
        selfdestruct(payable(msg.sender));
    }
}