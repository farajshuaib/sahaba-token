// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "./OwnerWithdrawable.sol";

contract SahabaSwap is OwnerWithdrawable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20Metadata;

    //Rate wrt to Native Currency of the chain
    uint256 public rate;

    // Token for which swap is being done
    address public saleToken;
    uint public saleTokenDecimal;

    //Total tokens to be sold in the swap
    uint256 public totalTokensforSale;

    // Whitelist of tokens to buy from
    mapping(address => bool) public tokenWL;

    // 1 Token price in terms of WL tokens
    mapping(address => uint256) public tokenPrices;

    uint256 public totalTokensSold;

    constructor(address _saleToken, uint256 _rate) {
        saleToken = _saleToken;
        rate = _rate;
        totalTokensforSale = IERC20Metadata(_saleToken).totalSupply();
        saleTokenDecimal = IERC20Metadata(_saleToken).decimals();
        // IERC20(saleToken).safeTransferFrom(
        //     msg.sender,
        //     address(this),
        //     totalTokensforSale
        // );
    }

    // Add a token to buy swap token from, with price
    function addWhiteListedToken(
        address[] memory _tokens,
        uint256[] memory _prices
    ) external onlyOwner {
        require(
            _tokens.length == _prices.length,
            "swap: tokens & prices arrays length mismatch"
        );

        for (uint256 i = 0; i < _tokens.length; i++) {
            require(_prices[i] != 0, "swap: Cannot set price to 0");
            tokenWL[_tokens[i]] = true;
            tokenPrices[_tokens[i]] = _prices[i];
        }
    }

    function updateTokenRate(
        address[] memory _tokens,
        uint256[] memory _prices,
        uint256 _rate
    ) external onlyOwner {
        require(
            _tokens.length == _prices.length,
            "swap: tokens & prices arrays length mismatch"
        );

        if (_rate != 0) {
            rate = _rate;
        }

        for (uint256 i = 0; i < _tokens.length; i += 1) {
            require(tokenWL[_tokens[i]] == true, "swap: Token not whitelisted");
            require(_prices[i] != 0, "swap: Cannot set rate as 0");
            tokenPrices[_tokens[i]] = _prices[i];
        }
    }

    // Public view function to calculate amount of sale tokens returned if you buy using "amount" of "token"
    function getTokenAmount(address token, uint256 amount)
        public
        view
        returns (uint256)
    {
        uint256 amtOut;
        if (token != address(0)) {
            require(tokenWL[token] == true, "swap: Token not whitelisted");
            // uint tokenDec = IERC20(token).decimals();
            uint256 price = tokenPrices[token];
            amtOut = amount.mul(10**saleTokenDecimal).div(price);
        } else {
            amtOut = amount.mul(10**saleTokenDecimal).div(rate);
        }
        return amtOut;
    }

    // Public Function to buy tokens. APPROVAL needs to be done first
    function buyToken(address _token, uint256 _amount) external payable {
        uint256 saleTokenAmt;
        if (_token != address(0)) {
            require(_amount > 0, "swap: Cannot buy with zero amount");
            require(tokenWL[_token] == true, "swap: Token not whitelisted");

            saleTokenAmt = getTokenAmount(_token, _amount);
            IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        } else {
            saleTokenAmt = getTokenAmount(address(0), msg.value);
        }
        require(
            (totalTokensSold + saleTokenAmt) < totalTokensforSale,
            "swap: Total Token Sale Reached!"
        );
        IERC20(saleToken).safeTransfer(msg.sender, saleTokenAmt);
        // Update Stats
        totalTokensSold += saleTokenAmt;
    }
}
