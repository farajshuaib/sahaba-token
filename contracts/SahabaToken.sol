// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SahabaToken is ERC20 {
    constructor() ERC20("SahabaToken", "SHB") {
        // Define the supply of SahabaToken: 1,000,000
        _mint(msg.sender, 1000000 * (10**18));
    }
}
