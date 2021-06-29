// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.7.0;

import "./FluxStakePrizePool.sol";
import "../../external/openzeppelin/ProxyFactory.sol";
import "@openzeppelin/contracts/proxy/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/TransparentUpgradeableProxy.sol";
/// @title Compound Prize Pool Proxy Factory
/// @notice Minimal proxy pattern for creating new Compound Prize Pools
contract FluxStakePrizePoolProxyFactory  {

  /// @notice Contract template for deploying proxied Prize Pools
  CfxStakePrizePool public instance;
  ProxyAdmin public proxyAdmin;

  /// @notice Initializes the Factory with an instance of the Compound Prize Pool
  constructor (ProxyAdmin _proxyAdmin) public {
    instance = new FluxStakePrizePool();
    proxyAdmin= _proxyAdmin;
  }

  /// @notice Creates a new Compound Prize Pool as a proxy of the template instance
  /// @return A reference to the new proxied Compound Prize Pool
  function create() external returns (FluxStakePrizePool) {
    address proxyAddress = address(new TransparentUpgradeableProxy(address(instance),address(proxyAdmin), new bytes(0)));
    return FluxStakePrizePool(proxyAddress);
  }
}
