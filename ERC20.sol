pragma solidity^0.5.7;


contract ERC20Interface {
    function totalSupply() public view returns (uint256 totalSupply);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    
    function deposit() public payable;
    function withdraw(uint256 _value) public returns (bool success);
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract MyToken is ERC20Interface {
    // mapping from account address to current balance
    mapping(address => uint256) _accountBalances;
    
    // mapping from account owner to accounts allowed to withdraw 
    // specified amounts
    mapping(address => mapping(address => uint256)) _approvals;
    
    uint256 private _totalSupply = 0;

    string public name = "rez27"; // TODO CHANGE THIS!

    function deposit() public payable {
        

        uint wei_deposited = msg.value;
        uint tokens_to_credit = msg.value / 1000;
        _accountBalances[msg.sender] += tokens_to_credit;
        _totalSupply += tokens_to_credit;
        // check that deposit doesn't overflow total_supply
        require(_totalSupply + tokens_to_credit >= _totalSupply);
        
        uint amount_to_refund = wei_deposited - (tokens_to_credit * 1000);
        if (amount_to_refund != 0) {
            msg.sender.transfer(amount_to_refund);
        }
        emit Transfer(address(0x0), msg.sender, tokens_to_credit);
    }

function withdraw(uint256 _value) public returns (bool success) {
        // Make sure the user's balance is sufficient
        // (otherwise throw)
        require(
            _accountBalances[msg.sender] >= _value,
            "Insufficient funds!"
        );
        // Adjust data structures appropriately
        _accountBalances[msg.sender] -= _value;
        _totalSupply -= _value;
        // Send appropriate amount of Ether from contract's reserves
        // (throw if send fails)
        if(msg.sender.send(_value * 1000)) {
            emit Transfer(msg.sender, address(0x0), _value);
            return true;
        } else {
            return false;
        }
        // Issue log of transfer to 0x0 (represents burning of tokens in spec)
    }
    
    function totalSupply() public view returns (uint256 total_supply) {
        return _totalSupply;
    }
    
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return _accountBalances[_owner];   
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if ( _accountBalances[msg.sender] >= _value  // sender has enough resources
        ){
            _accountBalances[msg.sender] -= _value;
            _accountBalances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        }
        
        revert();
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if ( _approvals[_from][msg.sender] >= _value  // sender is approved to withdraw
             && _accountBalances[_from] >= _value  // origin account has enough resources
        ){
            _approvals[_from][msg.sender] -= _value;
            _accountBalances[_from] -= _value;
            _accountBalances[_to] += _value;
            emit Transfer(_from, _to, _value);
            return true;
        }
        
        revert();   
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        _approvals[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return _approvals[_owner][_spender];   
    }
}