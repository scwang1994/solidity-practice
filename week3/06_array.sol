// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Array - dynamic or fixed size
// Initialization
// Insert (push), get, update, delete, pop, length
// Creating array in memory
// Returning array from function

contract Array {
    uint[] public nums = [1, 2, 3];
    uint[3] public numsFixed = [4, 5, 6];

    function examples() external {
        nums.push(4); // [1, 2, 3, 4] 
        uint x = nums[1];
        nums[2] = 777; // [1, 2, 777, 4];
        delete nums[1]; // [1, 0, 777, 4];
        nums.pop(); // [1, 0, 777];
        uint len = nums.length; // 3

        // create array in memory
        uint[] memory a = new uint[](5);
        a[1] = 123;
    }

    function returnArray() external view returns (uint[] memory) {
        return nums;
    }
    // not recommended
    /* 
    return it now returning the array from a function is not recommended. 
    the reason is similar to why you would want to keep your for loop small the bigger the array.
    the more gas it will use if the array is too big it can use up all of the gas. 
    and this function will be unusable so in summary you can write a function that returns an array but it is not recommended 
    */
}