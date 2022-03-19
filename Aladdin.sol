pragma solidity 0.5.16;

interface IERC20 {
  
  function totalSupply() external view returns (uint256);

  
  function decimals() external view returns (uint8);

  
  function symbol() external view returns (string memory);

  
  function name() external view returns (string memory);

  
  function getOwner() external view returns (address);

  
  function balanceOf(address account) external view returns (uint256);

  
  function transfer(address recipient, uint256 amount) external returns (bool);

  
  function allowance(address _owner, address spender) external view returns (uint256);

  
  function approve(address spender, uint256 amount) external returns (bool);

  
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  
  event Transfer(address indexed from, address indexed to, uint256 value);

  
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Context {
  
  
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; 
    return msg.data;
  }
}


library SafeMath {
  
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    
    require(b > 0, errorMessage);
    uint256 c = a / b;
    

    return c;
  }

  
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}


contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  
  function owner() public view returns (address) {
    return _owner;
  }

  
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract Aladdin is Context, IERC20, Ownable {
    using SafeMath for uint256;



    
    mapping (address => uint256) private _balances;

    
    
    mapping (address => mapping (address => uint256)) private _allowances;

    
    address[] private _pools;
    mapping(address => bool) private _isPoolExist;

    
    address private _originalFundAccount;
    
    address private _returnFundAccount;
    
    address private _commissionFundAccount;

    
    uint256 private _totalSupply;
    
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    constructor() public{
        _name = "Aladdin";
        _symbol = "ALD";
        _decimals = 6;
        _totalSupply = 210000000 * (10 ** uint256(_decimals));
        
        
        _balances[address(0)] = 208950000 * (10 ** uint256(_decimals));

        
        _originalFundAccount = address(0x3E1122c42Ad74b8d3f568A58e162FfC94e2e026c);
        _balances[_originalFundAccount] = 1050000 * (10 ** uint256(_decimals));
        
        _returnFundAccount = address(0x5ea5737FA34393f9d85ae3eBfb12A7EEda321FbF);
        
        _commissionFundAccount = address(0xec60b39b0bc7DA1AEFB1946b9e681D77EB0a65d1);
        
        emit Transfer(address(0), address(0), _balances[address(0)]);
    }

    
    function getOwner() external view returns (address) {
        return owner();
    }

    
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    
    function name() external view returns (string memory) {
        return _name;
    }

    
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    
    function pools() external view returns (address[] memory) {
        return _pools;
    }

    
    function totalReward() external view returns (uint256) {
        return _balances[address(0)];
    }

       
    function transfer(address recipient, uint256 amount) external returns (bool) {
        return _ALDtransfer(_msgSender(),recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        
        
        _ALDtransfer(sender, recipient, amount);

        
        
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        
        return true;
    }

    
    function _ALDtransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        
        if((_isPoolExist[sender]&&_isPoolExist[recipient])||!(_isPoolExist[sender]||_isPoolExist[recipient])){
            _transfer(sender, recipient, amount);
            return true;
        }
        if(_isPoolExist[sender]){
            
            uint reward; 
            
            if(amount > _balances[sender]){
                require(amount<=_balances[address(0)], "ALD: not enought token in the pool or the totalReward");
                _mint(sender, amount);
            }
            
            if(amount.div(10 ** uint256(_decimals))>=50){
                
                
                if(_balances[address(0)] > 0){
                    reward = amount.div(100);
                    
                    if(reward > _balances[address(0)]){
                        
                        _mint(recipient, _balances[address(0)]);
                        reward = _balances[address(0)];
                    }
                    else{
                        
                        _mint(recipient, reward);
                    }
                }
                else{
                    reward = 0;
                }
            }
            else {
                reward = 0;
            }
            
            uint commission = amount.div(1000).mul(3);
            
            uint returnFund = amount.div(10000).mul(_getFund(amount));


            
            amount = amount.sub(commission).sub(returnFund);
            
            
            _transfer(sender, recipient, amount);
            
            
            _transfer(sender, _returnFundAccount, returnFund);

            
            _transfer(sender, _returnFundAccount, commission.div(6).mul(5));
            
            _transfer(sender, _commissionFundAccount, commission.div(6));
        }
        else{
            
            
            uint commission = amount.div(1000).mul(3);
            
            
            uint destroyFund = amount.div(10000).mul(_getFund(amount));
            
            require(amount.add(commission).add(destroyFund)<=_balances[sender], "ALD: transfer amount exceeds balance");

            
            _transfer(sender, recipient, amount);
            
            
            _burn(sender, destroyFund);

            
            _transfer(sender, _returnFundAccount, commission.div(6).mul(5));
            
            _transfer(sender, _commissionFundAccount, commission.div(6));
        }
        return true;
    }

    
    function _getFund(uint256 amount) internal view returns(uint256) {
        amount = amount.div(10 ** uint256(_decimals));
        if(amount <= 300){
            return 3;
        }
        else if(amount <= 500){
            return 5;
        }
        else if(amount <= 1000){
            return 8;
        }else{
            return 50;
        }
    }

    
    function addPool(address pool) external onlyOwner{
        require(!_isPoolExist[pool], "ALD: pool already exist");
        _pools.push(pool);
        _isPoolExist[pool] = true;
    }

    
    function forceAddPool(address pool) external onlyOwner{
        
        if(!_isPoolExist[pool]){
            for(uint i = 0; i < _pools.length; i++){
                if(_pools[i]==pool) break;
                if(i==_pools.length-1) _pools.push(pool);
            }
        }
        _isPoolExist[pool] = true;
    }

    
    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ALD: decreased allowance below zero"));
        return true;
    }
    
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ALD: transfer from the zero address");
        require(recipient != address(0), "ALD: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ALD: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ALD: mint to the zero address");

        _balances[address(0)] = _balances[address(0)].sub(amount);
        _balances[account] = _balances[account].add(amount);
        
        emit Transfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ALD: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ALD: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

        
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ALD: approve from the zero address");
        require(spender != address(0), "ALD: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    
    function _burnFrom(address account, uint256 amount) internal {
        
        
        _burn(account, amount);
        
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ALD: burn amount exceeds allowance"));
    }
}