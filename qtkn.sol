// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract tokenQTKN is ERC20, Ownable{
    //price
    uint256 public price = 0.01 ether;

    //creation of token
    constructor() ERC20("QTKN", "QTKN") {}

    //mint function
    //anyone can mint
    //has to pay price corresponding to the amount they are buying
    function mint(address _to, uint256 _amount) public payable {
        require(msg.value == (_amount*price));
        _mint(_to, _amount);
    }

    
}
