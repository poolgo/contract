pragma solidity >=0.6.0 <0.7.0;

import "../conflux-built-in/AdminControl.sol";
import "../conflux-built-in/SponsorWhitelistControl.sol";
import "../conflux-built-in/Staking.sol";
import "./PCFX.sol";
import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@pooltogether/fixed-point/contracts/FixedPoint.sol";

import "./TokenControllerInterface.sol";

// import "hardhat/console.sol";

contract CfxStake is Initializable, ContextUpgradeable {
    PCFX public underlying;
    uint256 public lastStakeBalance;
    uint256 public lastBlockNumber;
    uint256 public lastBlockTimeStamp;
    TokenControllerInterface public controller;

    Staking public constant STAKING =
        Staking(address(0x0888000000000000000000000000000000000002));

    function initialize(PCFX _token, TokenControllerInterface _controller)
        public
        virtual
        initializer
    {
        require(address(_token) != address(0), "token is not defined");
        underlying = _token;
        controller = _controller;
    }

    fallback() external payable {}

    function _stake() internal {
        if (address(this).balance >= 1e18) {
            STAKING.deposit(address(this).balance);
        }
    }

    function mint(uint256 amount) external onlyController returns (uint256) {
        require(
            underlying.transferFrom(msg.sender, address(this), amount),
            "could not transfer tokens"
        );
        underlying.withdraw(amount);
        STAKING.withdraw(balanceOfStakingBalance());
        lastStakeBalance = address(this).balance;
        lastBlockNumber = block.number;
        lastBlockTimeStamp = block.timestamp;
        _stake();
        return 0;
    }

    // function getCash() external view returns (uint256) {
    //     return underlying.balanceOf(address(this));
    // }

    function redeemUnderlying(uint256 requestedAmount)
        external
        onlyController
        returns (uint256)
    {
        STAKING.withdraw(balanceOfStakingBalance());
        underlying.deposit.value(requestedAmount)();
        require(
            underlying.transfer(msg.sender, requestedAmount),
            "could not transfer tokens"
        );
        lastStakeBalance = address(this).balance;
        lastBlockNumber = block.number;
        lastBlockTimeStamp = block.timestamp;
        _stake();
    }

    modifier onlyController {
        require(
            _msgSender() == address(controller),
            "ControlledToken/only-controller"
        );
        _;
    }

    function balanceOfStakingBalance() public view returns (uint256) {
        return STAKING.getStakingBalance(address(this));
    }
    // function balanceOfUnderlyingViewFast() public view returns (uint256) {
    //     uint256 diff = block.timestamp - lastBlockTimeStamp;
    //     uint256 fixedDiff = FixedPoint.calculateMantissa(diff,3153600000);
    //     uint256 rate = fixedDiff* 408;
    //     uint256 interest = FixedPoint.multiplyUintByMantissa(lastStakeBalance, rate);
    //     return lastStakeBalance + interest;
    // }
    function balanceOfUnderlyingView() public view returns (uint256) {
        uint256 fixedNum = FixedPoint.calculateMantissa(4, 6307200000);
        uint256 fixedBase = 1e18 + fixedNum;
        uint256 rate = fixedBase;
        uint256 result;
        if (lastStakeBalance > 1e18) {
            for (uint256 i = lastBlockNumber; i < block.number; i++) {
                rate = FixedPoint.multiplyUintByMantissa(rate, fixedBase);
            }
            result = FixedPoint.multiplyUintByMantissa(lastStakeBalance, rate);
        } else {
            result = lastStakeBalance;
        }
        return result;
    }

    function balanceOfUnderlying(address account) public returns (uint256) {
        STAKING.withdraw(STAKING.getStakingBalance(address(this)));

        lastStakeBalance = address(this).balance;
        lastBlockNumber = block.number;
        lastBlockTimeStamp = block.timestamp;
        _stake();
        return STAKING.getStakingBalance(address(this));
    }
}
