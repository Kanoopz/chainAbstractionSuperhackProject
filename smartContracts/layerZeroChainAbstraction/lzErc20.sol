// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./imports/contracts/token/ERC20/IERC20.sol";
import "./imports/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../layerZeroSolidityIntegration/contracts/lzApp/NonblockingLzApp.sol";


contract lzErc20 is NonblockingLzApp, IERC20, IERC20Metadata 
{
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    ///////////////////////////////////////////////////////////////////////////////////
    ////////////// layerZeroIntegration                                  //////////////
    ///////////////////////////////////////////////////////////////////////////////////

    bytes public constant PAYLOAD = "\x01\x02\x03\x04";
    uint256 public defaultGasFee = 200000;



    
    constructor(address _lzEndpoint) NonblockingLzApp(_lzEndpoint)
    {
        _name = "lzUsdToken";
        _symbol = "lzUsdT";
    }



    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

     function mint(address account, uint256 amount) public
     {
        _mint(account, amount);
     }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}



    ///////////////////////////////////////////////////////////////////////////////////
    ////////////// layerZeroIntegration                                  //////////////
    ///////////////////////////////////////////////////////////////////////////////////




    function _nonblockingLzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) internal override 
    {
        //bytes memory constructedPayload = abi.encode(msg.sender, paramNumberToTransfer);
        //(_tokenAddressPlaceHolder, _quantityToTransferPlaceHolder) = abi.decode(_payload, (address, uint));

        (address addressToTransfer, uint256 quantityToTransfer) = abi.decode(_payload, (address, uint256));

        uint256 actualAddressBalance = _balances[addressToTransfer];
        uint256 newAddressBalance = actualAddressBalance + quantityToTransfer;
        _balances[addressToTransfer] = newAddressBalance;
        
    }





    function estimateFee(uint16 _dstChainId, bytes calldata _payload, bool _useZro, bytes calldata _adapterParams) public view returns (uint nativeFee, uint zroFee) 
    {
        return lzEndpoint.estimateFees(_dstChainId, address(this), _payload, _useZro, _adapterParams);
    }

    function layerZeroTransfer(address paramDestinationAddressToTransfer, uint256 paramQuantityToTransfer, uint16 _dstChainId) public payable 
    {
        uint256 userBalance = _balances[msg.sender];
        require(userBalance >= paramQuantityToTransfer, "Not enough funds.");

        uint256 newUserBalance = userBalance - paramQuantityToTransfer;

        _balances[msg.sender] = newUserBalance;

        bytes memory constructedPayload = abi.encode(paramDestinationAddressToTransfer, paramQuantityToTransfer);

        uint16 valueOne = 1;
        uint256 valueTwo = 200000;
        bytes memory adapterParams = abi.encodePacked(valueOne, valueTwo);



        _lzSend(_dstChainId, constructedPayload, payable(tx.origin), address(0x0), adapterParams, msg.value);
    }





    function setOracle(uint16 dstChainId, address oracle) external onlyOwner {
        uint TYPE_ORACLE = 6;
        // set the Oracle
        lzEndpoint.setConfig(lzEndpoint.getSendVersion(address(this)), dstChainId, TYPE_ORACLE, abi.encode(oracle));
    }

    function getOracle(uint16 remoteChainId) external view returns (address _oracle) {
        bytes memory bytesOracle = lzEndpoint.getConfig(lzEndpoint.getSendVersion(address(this)), remoteChainId, address(this), 6);
        assembly {
            _oracle := mload(add(bytesOracle, 32))
        }
    }

   function makePathForThisContract(address paramRemoteAddress) public view returns(bytes memory)
   {
    return abi.encodePacked(paramRemoteAddress, address(this));
   }
}
