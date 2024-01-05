// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";
import {REVStageConfig} from "./structs/REVStageConfig.sol";
import "@openzeppelin/utils/Address.sol";

contract ContainerizedRevnet is ERC20 {
    address public boostOperator;
    REVStageConfig[] public stageConfigurations;

    error REVBasicDeployer_Unauthorized();
    error REVBasicDeployer_CannotRedeemMoreThanBalance();

    constructor(
        address boostOperator_,
        uint256 premintTokenAmount_,
        REVStageConfig[] memory stageConfigurations_,
        string memory tokenName_,
        string memory tokenTicker_
    ) ERC20(tokenName_, tokenTicker_) {
        _mint(boostOperator_, premintTokenAmount_);

        for (uint256 i = 0; i < stageConfigurations_.length; i++) {
            stageConfigurations.push(stageConfigurations[i]);
        }
    }

    function replaceBoostOperator(address newBoostOperator) external {
        /// Make sure the message sender is the current operator.
        if (msg.sender != boostOperator) revert REVBasicDeployer_Unauthorized();

        boostOperator = newBoostOperator;
    }

    function currentStage() public view returns (uint256 stageWeAreIn) {
        stageWeAreIn = stageConfigurations.length - 1;
        for (uint256 i = 0; i < stageConfigurations.length; i++) {
            if (block.timestamp < stageConfigurations[i].startsAtOrAfter) {
                continue;
            }
            stageWeAreIn = i;
            break;
        }
    }

    function pay() external payable {
        REVStageConfig memory currentStageConfig = stageConfigurations[currentStage()];

        _mint(msg.sender, (currentStageConfig.initialIssuanceRate * msg.value) * (1 - currentStageConfig.boostRate));
        _mint(boostOperator, (currentStageConfig.initialIssuanceRate * msg.value) * (currentStageConfig.boostRate));
    }

    function redeem(uint256 amt) external {
        if (balanceOf(msg.sender) < amt) revert REVBasicDeployer_CannotRedeemMoreThanBalance();
        REVStageConfig memory currentStageConfig = stageConfigurations[currentStage()];

        uint256 accessPerToken = (address(this).balance / totalSupply())
            * (
                (1 - currentStageConfig.priceFloorTaxIntensity)
                    + (currentStageConfig.priceFloorTaxIntensity / totalSupply())
            );

        _burn(msg.sender, amt);
        Address.sendValue(payable(msg.sender), accessPerToken * amt);
    }
}
