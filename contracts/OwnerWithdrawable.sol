// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract OwnerWithdrawable is Ownable {
    using SafeMath for uint256;

    receive() external payable {}

    fallback() external payable {}

    function withdraw(address token, uint256 amt) public onlyOwner {
        IERC20(token).transfer(msg.sender, amt);
    }

    function withdrawAll(address token) public onlyOwner {
        uint256 amt = IERC20(token).balanceOf(address(this));
        withdraw(token, amt);
    }

    function withdrawCurrency(uint256 amt) public onlyOwner {
        payable(msg.sender).transfer(amt);
    }

    // function deposit(address token, uint256 amt) public onlyOwner {
    //     uint256 allowance = IERC20(token).allowance(msg.sender, address(this));
    //     require(allowance >= amt, "Check the token allowance");
    //     IERC20(token).transferFrom(owner(), address(this), amt);
    // }
}

