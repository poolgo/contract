pragma solidity >=0.6.0 <0.7.0;

import "@pooltogether/pooltogether-rng-contracts/contracts/RNGInterface.sol";

contract RNGService is RNGInterface {

  uint256 internal random;

  function getLastRequestId() external override view returns (uint32 requestId) {
    return 1;
  }

  /// @return _feeToken
  /// @return _requestFee
  function getRequestFee() external override view returns (address _feeToken, uint256 _requestFee) {
    return (address(0), 0);
  }

  function setRandomNumber(uint256 _random) external {
    random = _random;
  }

  function requestRandomNumber() external override returns (uint32, uint32) {
    return (1, 1);
  }

  function isRequestComplete(uint32) external override view returns (bool) {
    return true;
  }

  function randomNumber(uint32) external override returns (uint256) {
    return randint();
  }
    function rand(uint256 seed) internal pure returns (uint256) {
        bytes32 data;
        if (seed % 2 == 0){
            data = keccak256(abi.encodePacked(seed));
        }else{
            data = keccak256(abi.encodePacked(keccak256(abi.encodePacked(seed))));
        }
        uint256 sum;
        for(uint256 i;i < 32;i++){
            sum += uint8(data[i]);
        }
        return uint8(data[sum % data.length])*uint8(data[(sum + 2) % data.length]);
    }
    function randint() internal view returns(uint) {
        return rand(block.timestamp );
    }
}