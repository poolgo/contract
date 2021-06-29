// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.7.0;

import "./Ticket.sol";
import "@pooltogether/fixed-point/contracts/FixedPoint.sol";

contract FomoTicket is Ticket {
  mapping (address => uint256) public ticketBalances;
  uint256 public ticketSupply;
  uint256 public beginTime ;

  bytes32 constant private TREE_KEY = keccak256("PoolGo/Ticket");
  uint256 constant private MAX_TREE_LEAVES = 5;

  /// @notice Initializes the Controlled Token with Token Details and the Controller
  /// @param _name The name of the Token
  /// @param _symbol The symbol for the Token
  /// @param _decimals The number of decimals for the Token
  /// @param _controller Address of the Controller contract for minting & burning
  function initialize(
    string memory _name,
    string memory _symbol,
    uint8 _decimals,
    TokenControllerInterface _controller
  )
    public
    virtual override
    initializer
  {
    beginTime =  _currentTime();
    reduceRate = 3963723990000;
    minimumChance = 8e17;
    notWinThreshold = 1e20;
    notWinOdds = 2e18;
    super.initialize(_name, _symbol, _decimals, _controller);
  }


  /// @notice Selects a user using a random number.  The random number will be uniformly bounded to the ticket totalSupply.
  /// @param randomNumber The random number to use to select a user.
  /// @return The winner
  function draw(uint256 randomNumber) external view override returns (address) {
    uint256 bound;
    if (totalSupply()>notWinThreshold){
      bound = FixedPoint.multiplyUintByMantissa(ticketSupply,notWinOdds);
    }else{
      bound = ticketSupply;
    }
    address selected;
    if (bound == 0) {
      selected = address(0);
    } else  {
      uint256 token = UniformRandomNumber.uniform(randomNumber, bound);
      if (token>=ticketSupply){
        return address(0);
      }
      selected = address(uint256(sortitionSumTrees.draw(TREE_KEY, token)));
    }
    return selected;
  }

  /// @dev Gets the current time as represented by the current block
  /// @return The timestamp of the current block
  function _currentTime() internal virtual view returns (uint256) {
    return block.timestamp;
  }
  /// @dev Controller hook to provide notifications & rule validations on token transfers to the controller.
  /// This includes minting and burning.
  /// May be overridden to provide more granular control over operator-burning
  /// @param from Address of the account sending the tokens (address(0x0) on minting)
  /// @param to Address of the account receiving the tokens (address(0x0) on burning)
  /// @param amount Amount of tokens being transferred
  function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
    require(_currentTime()>beginTime,"not started");
    super._beforeTokenTransfer(from, to, amount);

    // optimize: ignore transfers to self
    if (from == to) {
      return;
    }
    if (from == address(0)) {
      if (to != address(0)) {
        
        uint256 diff = (_currentTime()-beginTime)*reduceRate;
        if (diff>minimumChance){
          diff = minimumChance;
        }
        uint256 finalTicketAmount = FixedPoint.multiplyUintByMantissa(1e18-diff,amount);
        ticketBalances[to] = ticketBalances[to].add(finalTicketAmount);
        ticketSupply = ticketSupply.add(finalTicketAmount);
        
        sortitionSumTrees.set(TREE_KEY, ticketBalances[to], bytes32(uint256(to)));

      }
    }
    if (from != address(0)){
      if (to == address(0)){
          uint256 burunedFinalTicketAmount = amount*ticketBalances[from]/balanceOf(from);
          require(ticketBalances[from]>=burunedFinalTicketAmount,"error finalTicket");
          ticketBalances[from] = ticketBalances[from].sub(burunedFinalTicketAmount);
          ticketSupply = ticketSupply.sub(burunedFinalTicketAmount);

          sortitionSumTrees.set(TREE_KEY,  ticketBalances[from], bytes32(uint256(from)));
      }
    }

    if (from != address(0)) {
      if (to != address(0)) {
        uint256 burunedFinalTicketAmount = amount*ticketBalances[from]/balanceOf(from);
        require(ticketBalances[from]>=burunedFinalTicketAmount,"error finalTicket");
        ticketBalances[from] = ticketBalances[from].sub(burunedFinalTicketAmount);
        sortitionSumTrees.set(TREE_KEY, ticketBalances[from] , bytes32(uint256(from)));
        ticketBalances[to] = ticketBalances[to].add(burunedFinalTicketAmount);
        sortitionSumTrees.set(TREE_KEY, ticketBalances[to], bytes32(uint256(to)));
      }
    }
  }

}