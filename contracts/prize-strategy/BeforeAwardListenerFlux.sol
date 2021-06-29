// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.12;

import "./BeforeAwardListenerInterface.sol";
import "../Constants.sol";
import "./BeforeAwardListenerLibrary.sol";
import "../../prize-pool/FluxStake/FluxStakePrizePool.sol";

contract BeforeAwardListenerFlux is BeforeAwardListener {
  
  FluxStakePrizePool public fluxPrizePool;

  constructor(address _fluxPrizePool) public {
      fluxPrizePool = _fluxPrizePool;
  }
  function beforePrizePoolAwarded(uint256 randomNumber, uint256 prizePeriodStartedAt) external{
      fluxPrizePool.claimFlux();
  }
}