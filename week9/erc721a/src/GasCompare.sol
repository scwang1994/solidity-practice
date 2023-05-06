// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721A} from "./ERC721A.sol";

contract ERC721Example is ERC721Enumerable {
    constructor() ERC721("ERC721 Coin", "EC") {}

    function eMint(address to, uint tokenId) public {
        _safeMint(to, tokenId);
    }

    function eApprove(address to, uint256 tokenId) public {
        _approve(to, tokenId);
    }

    function eTransferFrom(address from, address to, uint256 tokenId) public {
        _transfer(from, to, tokenId);
    }
}

contract ERC721AExample is ERC721A {
    constructor() ERC721A("ERC721A Coin", "EAC") {}

    function aMint(address to, uint256 quantity) public {
        _mint(to, quantity);
    }

    function aApprove(address to, uint256 tokenId) public {
        approve(to, tokenId);
    }

    function aTransferFrom(address from, address to, uint256 tokenId) public {
        transferFrom(from, to, tokenId);
    }
}
