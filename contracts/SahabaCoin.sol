// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SahabaCoin is ERC20, Ownable {
    constructor() ERC20("SahabaCoin", "SHB") {
        // Define the supply of SahabaCoin: 1,000,000
        _mint(msg.sender, 1000000 * (10**18));
    }
}
