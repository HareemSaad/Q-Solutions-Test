// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 < 0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract Certificate is ERC721, Ownable {
    uint256 public id = 0;

    constructor() ERC721 ("QTKN", "QTKN") {}

    function mint (address _to) public onlyOwner {
        id += 1;
        _safeMint(_to, id);
    }
}
