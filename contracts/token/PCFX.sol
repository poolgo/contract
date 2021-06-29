pragma solidity >=0.5.0 <0.7.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "../conflux-built-in/SponsorWhitelistControl.sol";

contract PCFX is ERC20Upgradeable {

    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);
  SponsorWhitelistControl constant public SPONSOR = SponsorWhitelistControl(address(0x0888000000000000000000000000000000000001));

  function initialize()
    public
    virtual
    initializer
  {
    __ERC20_init("PoolGo CFX", "PCFX");
    _setupDecimals(18);

    
    address[] memory users = new address[](1);  
    users[0] = address(0);
    SPONSOR.addPrivilege(users);
  }

    fallback() external payable {
        deposit();
    }
    function deposit() public payable {
        _mint(msg.sender,msg.value);
        // _balances[msg.sender] += msg.value;
        Deposit(msg.sender, msg.value);
    }
    function withdraw(uint wad) public {
        require(balanceOf(msg.sender) >= wad,"no enough pcfx");
        _burn(msg.sender,wad);
        msg.sender.transfer(wad);
        Withdrawal(msg.sender, wad);
    }

}