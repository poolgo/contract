// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.7.0;


interface FluxMintInterface {
    function claimFlux() external;
    function claimDaoFlux() external;
    function getFluxRewards(address pool,uint8 kind,address user) external view returns (uint256 reward);
    function remainFluxByUser(address user)external view returns(uint256 reward);
}
