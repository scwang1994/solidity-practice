// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.17;

import "./CErc20Delegator.sol";
import "./CErc20Delegate.sol";
import "./Unitroller.sol";
import "./SimplePriceOracle.sol";
import "./WhitePaperInterestRateModel.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyCompound {
    // Token public uni;
    CErc20Delegator public cMT;
    CErc20Delegate public cMTDelegate;
    Unitroller public unitroller;
    // ComptrollerG1	public comptroller;
    // ComptrollerG1	public unitrollerProxy;
    SimplePriceOracle public priceOracle;
    WhitePaperInterestRateModel public whitePaper;

    constructor() payable {
        priceOracle = new SimplePriceOracle();
        whitePaper = new WhitePaperInterestRateModel(0, 0);
        cMTDelegate = new CErc20Delegate();
        mt = ERC20("MyToken", "MT");

        cMT = new CErc20Delegator(
            address(mt),
            ComptrollerInterface(address(unitroller)),
            InterestRateModel(address(whitePaper)),
            1,
            "Compound MyToken",
            "cMT",
            18,
            address(uint160(address(this))),
            address(cMTDelegate),
            0x00
        );
    }
}
