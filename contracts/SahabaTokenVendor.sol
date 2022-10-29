// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "./SahabaToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SahabaTokenVendor is Ownable {
    SahabaToken tokenContract;
    uint256 private tokenPrice = 1000000000000000; // in wei
    event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);

    constructor(address tokenAddress) {
        tokenContract = SahabaToken(tokenAddress);
    }

    function buyTokens() public payable returns (uint256 tokenAmount) {
        require(msg.value > 0, "You need to send some Eth to proceed");
        uint256 amountToBuy = msg.value * tokenPrice;

        uint256 vendorBalance = tokenContract.balanceOf(address(this));
        require(vendorBalance >= amountToBuy, "Vendor has insufficient tokens");

        bool sent = tokenContract.transfer(msg.sender, amountToBuy);
        require(sent, "Failed to transfer token to user");

        emit BuyTokens(msg.sender, msg.value, amountToBuy);
        return amountToBuy;
    }

    function getTokenPrice() public view returns (uint256) {
        return tokenPrice;
    }

    function sellTokens(uint256 tokenAmountToSell) public {
        require(
            tokenAmountToSell > 0,
            "Specify an amount of token greater than zero"
        );

        uint256 userBalance = tokenContract.balanceOf(msg.sender);
        require(
            userBalance >= tokenAmountToSell,
            "You have insufficient tokens"
        );

        uint256 amountOfEthToTransfer = tokenAmountToSell / tokenPrice;
        uint256 ownerEthBalance = address(this).balance;
        require(
            ownerEthBalance >= amountOfEthToTransfer,
            "Vendor has insufficient funds"
        );
        bool sent = tokenContract.transferFrom(
            msg.sender,
            address(this),
            tokenAmountToSell
        );
        require(sent, "Failed to transfer tokens from user to vendor");

        (sent, ) = msg.sender.call{value: amountOfEthToTransfer}("");
        require(sent, "Failed to send ETH to the user");
    }

    function withdraw() public onlyOwner {
        uint256 ownerBalance = address(this).balance;
        require(ownerBalance > 0, "No ETH present in Vendor");
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to withdraw");
    }

    function totalTokenForSale() public view returns (uint256) {
        return tokenContract.balanceOf(address(this));
    }

}
