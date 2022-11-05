// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "./SahabaToken.sol";
import "./Crowdsale.sol";
import "./KycContract.sol";

contract ICO is Crowdsale {
    KycContract kyc;

    constructor(
        uint256 _rate,
        address payable _wallet,
        IERC20 _token,
        KycContract _kyc
    )  Crowdsale(_rate, _wallet, _token) {
        kyc = _kyc;
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount)
        internal
        view
        override
    {
        super._preValidatePurchase(beneficiary, weiAmount);
        require(
            kyc.kycStatus(msg.sender),
            "KYC is not completed, purchase is prohibited"
        );
    }
}
