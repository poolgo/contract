// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.7.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface FluxMarketInterface is IERC20Upgradeable {
    function getAcctSnapshot(address acct) external view returns (uint256 ftokens,uint256 borrows,uint256 xrate);
    function mint(uint256 amount) external returns (uint256);
    function redeem(uint256 underlyings) external returns (uint256);
}
