// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {ERC721Example, ERC721AExample} from "../src/GasCompare.sol";

contract GasTest is Test {
    ERC721Example public erc721;
    ERC721AExample public erc721a;

    address owner = makeAddr("owner");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    function setUp() public {
        erc721 = new ERC721Example();
        erc721a = new ERC721AExample();
    }

    function testMint5Times() public {
        // mint
        vm.prank(owner);
        // 1. Test ERC721 mint 5 tokens
        for (uint256 i = 0; i < 5; i++) {
            erc721.eMint(user1, erc721.totalSupply() + i);
        }
        // 2. Test ERC721A mint 5 tokens
        erc721a.aMint(user1, 5);
        vm.stopPrank();

        // approve
        vm.prank(user1);
        erc721.eApprove(user2, 0);
        vm.stopPrank();

        vm.prank(user1);
        erc721a.aApprove(user2, 4);
        vm.stopPrank();

        // transferFrom
        vm.prank(user2);
        erc721.eTransferFrom(user1, user2, 0);
        vm.stopPrank();

        vm.prank(user2);
        erc721a.aTransferFrom(user1, user2, 4);
        vm.stopPrank();
    }
}
