// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.7.0;

import "./MultipleWinners.sol";
import "../../external/openzeppelin/ProxyFactory.sol";
import "@openzeppelin/contracts/proxy/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/TransparentUpgradeableProxy.sol";

/// @title Creates a minimal proxy to the MultipleWinners prize strategy.  Very cheap to deploy.
contract MultipleWinnersProxyFactory is ProxyFactory {

  MultipleWinners public instance;
  ProxyAdmin public proxyAdmin;

  constructor (ProxyAdmin _proxyAdmin) public {
    instance = new MultipleWinners();
    proxyAdmin= _proxyAdmin;
  }

  function create() external returns (MultipleWinners) {
    address proxyAddress = address(new TransparentUpgradeableProxy(address(instance),address(proxyAdmin), new bytes(0)));
    return MultipleWinners(proxyAddress);
  }

}