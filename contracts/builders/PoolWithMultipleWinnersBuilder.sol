// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/utils/SafeCastUpgradeable.sol";

import "../registry/RegistryInterface.sol";
import "../prize-pool/cfx-stake/CfxStakePrizePoolProxyFactory.sol";
import "../prize-pool/flux-stake/FluxStakePrizePoolProxyFactory.sol";
import "../prize-pool/compound/CompoundPrizePoolProxyFactory.sol";
import "../prize-pool/yield-source/YieldSourcePrizePoolProxyFactory.sol";
import "../prize-pool/stake/StakePrizePoolProxyFactory.sol";
import "./MultipleWinnersBuilder.sol";

contract PoolWithMultipleWinnersBuilder {
  using SafeCastUpgradeable for uint256;

  event  CfxStakePrizePoolWithMultipleWinnersCreated(
    CfxStakePrizePool indexed prizePool,
    MultipleWinners indexed prizeStrategy
  );
  event CompoundPrizePoolWithMultipleWinnersCreated(
    CompoundPrizePool indexed prizePool,
    MultipleWinners indexed prizeStrategy
  );

  event YieldSourcePrizePoolWithMultipleWinnersCreated(
    YieldSourcePrizePool indexed prizePool,
    MultipleWinners indexed prizeStrategy
  );

  event StakePrizePoolWithMultipleWinnersCreated(
    StakePrizePool indexed prizePool,
    MultipleWinners indexed prizeStrategy
  );

  struct FluxStakePrizePoolConfig {
    FluxMarketInterface fluxMarket;
    FluxMintInterface fluxMint;
    uint256 maxExitFeeMantissa;
    uint256 maxTimelockDuration;
  }
  struct CfxStakePrizePoolConfig {
    CfxStake cfxStake;
    uint256 maxExitFeeMantissa;
    uint256 maxTimelockDuration;
  }
  /// @notice The configuration used to initialize the Compound Prize Pool
  struct CompoundPrizePoolConfig {
    CTokenInterface cToken;
    uint256 maxExitFeeMantissa;
    uint256 maxTimelockDuration;
  }

  /// @notice The configuration used to initialize the Compound Prize Pool
  struct YieldSourcePrizePoolConfig {
    YieldSourceInterface yieldSource;
    uint256 maxExitFeeMantissa;
    uint256 maxTimelockDuration;
  }

  struct StakePrizePoolConfig {
    IERC20Upgradeable token;
    uint256 maxExitFeeMantissa;
    uint256 maxTimelockDuration;
  }

  RegistryInterface public reserveRegistry;
  CfxStakePrizePoolProxyFactory public cfxStakePrizePoolProxyFactory;
  CompoundPrizePoolProxyFactory public compoundPrizePoolProxyFactory;
  YieldSourcePrizePoolProxyFactory public yieldSourcePrizePoolProxyFactory;
  StakePrizePoolProxyFactory public stakePrizePoolProxyFactory;
  MultipleWinnersBuilder public multipleWinnersBuilder;
  FluxStakePrizePoolProxyFactory public fluxStakePrizePoolProxyFactory;

  constructor (
    RegistryInterface _reserveRegistry,
    CfxStakePrizePoolProxyFactory _cfxStakePrizePoolProxyFactory,
    CompoundPrizePoolProxyFactory _compoundPrizePoolProxyFactory,
    YieldSourcePrizePoolProxyFactory _yieldSourcePrizePoolProxyFactory,
    StakePrizePoolProxyFactory _stakePrizePoolProxyFactory,
    MultipleWinnersBuilder _multipleWinnersBuilder
  ) public {
    require(address(_reserveRegistry) != address(0), "GlobalBuilder/reserveRegistry-not-zero");
    reserveRegistry = _reserveRegistry;
    cfxStakePrizePoolProxyFactory = _cfxStakePrizePoolProxyFactory;
    compoundPrizePoolProxyFactory = _compoundPrizePoolProxyFactory;
    yieldSourcePrizePoolProxyFactory = _yieldSourcePrizePoolProxyFactory;
    stakePrizePoolProxyFactory = _stakePrizePoolProxyFactory;
    multipleWinnersBuilder = _multipleWinnersBuilder;
  }
  constructor (
    RegistryInterface _reserveRegistry,
    FluxStakePrizePoolProxyFactory _fluxStakePrizePoolProxyFactory,
    CfxStakePrizePoolProxyFactory _cfxStakePrizePoolProxyFactory,
    CompoundPrizePoolProxyFactory _compoundPrizePoolProxyFactory,
    YieldSourcePrizePoolProxyFactory _yieldSourcePrizePoolProxyFactory,
    StakePrizePoolProxyFactory _stakePrizePoolProxyFactory,
    MultipleWinnersBuilder _multipleWinnersBuilder
  ) public {
    require(address(_reserveRegistry) != address(0), "GlobalBuilder/reserveRegistry-not-zero");
    reserveRegistry = _reserveRegistry;
    fluxStakePrizePoolProxyFactory = _fluxStakePrizePoolProxyFactory;
    cfxStakePrizePoolProxyFactory = _cfxStakePrizePoolProxyFactory;
    compoundPrizePoolProxyFactory = _compoundPrizePoolProxyFactory;
    yieldSourcePrizePoolProxyFactory = _yieldSourcePrizePoolProxyFactory;
    stakePrizePoolProxyFactory = _stakePrizePoolProxyFactory;
    multipleWinnersBuilder = _multipleWinnersBuilder;
  }

function createFluxStakeMultipleWinners(
    FluxStakePrizePoolConfig memory prizePoolConfig,
    MultipleWinnersBuilder.MultipleWinnersConfig memory prizeStrategyConfig,
    uint8 decimals
  ) external returns (CfxStakePrizePool) {
    FluxStakePrizePool prizePool = fluxStakePrizePoolProxyFactory.create();
    MultipleWinners prizeStrategy = multipleWinnersBuilder.createMultipleWinners(
      prizePool,
      prizeStrategyConfig,
      decimals,
      msg.sender
    );
    
    BeforeAwardListenerFlux beforeWard = new BeforeAwardListenerFlux();
    prizeStrategy.setBeforeAwardListener(beforeWard);
    
    prizePool.initialize(
      reserveRegistry,
      _tokens(prizeStrategy),
      prizePoolConfig.maxExitFeeMantissa,
      prizePoolConfig.maxTimelockDuration,
      prizePoolConfig.fluxMarket,
      prizePoolConfig.fluxMint,
    );
    prizePool.setPrizeStrategy(prizeStrategy);
    prizePool.setCreditPlanOf(
      address(prizeStrategy.ticket()),
      prizeStrategyConfig.ticketCreditRateMantissa.toUint128(),
      prizeStrategyConfig.ticketCreditLimitMantissa.toUint128()
    );
    prizePool.transferOwnership(msg.sender);
    emit CfxStakePrizePoolWithMultipleWinnersCreated(prizePool, prizeStrategy);
    return prizePool;
  }
  function createCfxStakeMultipleWinners(
    CfxStakePrizePoolConfig memory prizePoolConfig,
    MultipleWinnersBuilder.MultipleWinnersConfig memory prizeStrategyConfig,
    uint8 decimals
  ) external returns (CfxStakePrizePool) {
    CfxStakePrizePool prizePool = cfxStakePrizePoolProxyFactory.create();
    MultipleWinners prizeStrategy = multipleWinnersBuilder.createMultipleWinners(
      prizePool,
      prizeStrategyConfig,
      decimals,
      msg.sender
    );
    
    prizePool.initialize(
      reserveRegistry,
      _tokens(prizeStrategy),
      prizePoolConfig.maxExitFeeMantissa,
      prizePoolConfig.maxTimelockDuration,
      prizePoolConfig.cfxStake
    );
    prizePool.setPrizeStrategy(prizeStrategy);
    prizePool.setCreditPlanOf(
      address(prizeStrategy.ticket()),
      prizeStrategyConfig.ticketCreditRateMantissa.toUint128(),
      prizeStrategyConfig.ticketCreditLimitMantissa.toUint128()
    );
    prizePool.transferOwnership(msg.sender);
    emit CfxStakePrizePoolWithMultipleWinnersCreated(prizePool, prizeStrategy);
    return prizePool;
  }

  function createCompoundMultipleWinners(
    CompoundPrizePoolConfig memory prizePoolConfig,
    MultipleWinnersBuilder.MultipleWinnersConfig memory prizeStrategyConfig,
    uint8 decimals
  ) external returns (CompoundPrizePool) {
    CompoundPrizePool prizePool = compoundPrizePoolProxyFactory.create();
    MultipleWinners prizeStrategy = multipleWinnersBuilder.createMultipleWinners(
      prizePool,
      prizeStrategyConfig,
      decimals,
      msg.sender
    );
    prizePool.initialize(
      reserveRegistry,
      _tokens(prizeStrategy),
      prizePoolConfig.maxExitFeeMantissa,
      prizePoolConfig.maxTimelockDuration,
      CTokenInterface(prizePoolConfig.cToken)
    );
    prizePool.setPrizeStrategy(prizeStrategy);
    prizePool.setCreditPlanOf(
      address(prizeStrategy.ticket()),
      prizeStrategyConfig.ticketCreditRateMantissa.toUint128(),
      prizeStrategyConfig.ticketCreditLimitMantissa.toUint128()
    );
    prizePool.transferOwnership(msg.sender);
    emit CompoundPrizePoolWithMultipleWinnersCreated(prizePool, prizeStrategy);
    return prizePool;
  }

  function createYieldSourceMultipleWinners(
    YieldSourcePrizePoolConfig memory prizePoolConfig,
    MultipleWinnersBuilder.MultipleWinnersConfig memory prizeStrategyConfig,
    uint8 decimals
  ) external returns (YieldSourcePrizePool) {
    YieldSourcePrizePool prizePool = yieldSourcePrizePoolProxyFactory.create();
    MultipleWinners prizeStrategy = multipleWinnersBuilder.createMultipleWinners(
      prizePool,
      prizeStrategyConfig,
      decimals,
      msg.sender
    );
    prizePool.initializeYieldSourcePrizePool(
      reserveRegistry,
      _tokens(prizeStrategy),
      prizePoolConfig.maxExitFeeMantissa,
      prizePoolConfig.maxTimelockDuration,
      prizePoolConfig.yieldSource
    );
    prizePool.setPrizeStrategy(prizeStrategy);
    prizePool.setCreditPlanOf(
      address(prizeStrategy.ticket()),
      prizeStrategyConfig.ticketCreditRateMantissa.toUint128(),
      prizeStrategyConfig.ticketCreditLimitMantissa.toUint128()
    );
    prizePool.transferOwnership(msg.sender);
    emit YieldSourcePrizePoolWithMultipleWinnersCreated(prizePool, prizeStrategy);
    return prizePool;
  }

  function createStakeMultipleWinners(
    StakePrizePoolConfig memory prizePoolConfig,
    MultipleWinnersBuilder.MultipleWinnersConfig memory prizeStrategyConfig,
    uint8 decimals
  ) external returns (StakePrizePool) {
    StakePrizePool prizePool = stakePrizePoolProxyFactory.create();
    MultipleWinners prizeStrategy = multipleWinnersBuilder.createMultipleWinners(
      prizePool,
      prizeStrategyConfig,
      decimals,
      msg.sender
    );
    prizePool.initialize(
      reserveRegistry,
      _tokens(prizeStrategy),
      prizePoolConfig.maxExitFeeMantissa,
      prizePoolConfig.maxTimelockDuration,
      prizePoolConfig.token
    );
    prizePool.setPrizeStrategy(prizeStrategy);
    prizePool.setCreditPlanOf(
      address(prizeStrategy.ticket()),
      prizeStrategyConfig.ticketCreditRateMantissa.toUint128(),
      prizeStrategyConfig.ticketCreditLimitMantissa.toUint128()
    );
    prizePool.transferOwnership(msg.sender);
    emit StakePrizePoolWithMultipleWinnersCreated(prizePool, prizeStrategy);
    return prizePool;
  }

  function _tokens(MultipleWinners _multipleWinners) internal view returns (ControlledTokenInterface[] memory) {
    ControlledTokenInterface[] memory tokens = new ControlledTokenInterface[](2);
    tokens[0] = ControlledTokenInterface(address(_multipleWinners.ticket()));
    tokens[1] = ControlledTokenInterface(address(_multipleWinners.sponsorship()));
    return tokens;
  }

}
