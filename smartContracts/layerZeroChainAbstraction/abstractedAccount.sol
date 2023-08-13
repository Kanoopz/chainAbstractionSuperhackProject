//SPDX-License-Identifier: MIT

import { IWorldID } from './interfaces/IWorldID.sol';
import { iNft } from './interfaces/iNft.sol';
import { iLzErc20 } from './interfaces/iLzErc20.sol';

pragma solidity 0.8.10;

import { NonblockingLzApp } from "../layerZeroSolidityIntegration/contracts/lzApp/NonblockingLzApp.sol";

contract abstractedAccount is NonblockingLzApp
{
    ////////////////////////////////////////////////////////////////////////////
    /////"modifiers"////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////// 
    /*
    modifier onlyOwner()
    {
        require(msg.sender == owner, "notOwner.");
        _;
    }
    */

    /*
        modifier onlyOwnerOrWorldId()
        {
            
        }
    */

    ////////////////////////////////////////////////////////////////////////////
    /////"generalVariables"/////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////// 
    //address public owner;
    address public factoryAddress;
    address public crossChainAaAddress;
    //DOMINIO//  
    address public usdTokenAddress; //USDTOKEN ADDRESS ON THIS CHAIN//

    uint8 public nftCounter;
    uint8 public tokenCounter;

    address[] public nftAddresses;
    address[] public tokenAddresses;

    /////"worldcoinVariables"///////////////////////////////////////////////////
    bool public isWorldIdSet;
    uint256 public ownerWorldIdNullifierHash;

    //IWorldID internal immutable worldId;
    //uint256 internal immutable externalNullifierHash;
    //uint256 internal immutable groupId = 1;
    IWorldID internal worldId;
    uint256 internal externalNullifierHash;
    uint256 internal immutable groupId = 1;

    ////////////////////////////////////////////////////////////////////////////
    /////"functions"////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////  
    //DOMINIO DE LA CCAA)
    constructor(address paramOwner, address paramFactoryAddress, address _lzEndpoint, address srcChainUsdTokenAddress) NonblockingLzApp(_lzEndpoint)
    {
        //owner = paramOwner;
        factoryAddress = paramFactoryAddress;
        usdTokenAddress = srcChainUsdTokenAddress;
    }

    /*
        function setWorldId(uint256 variables) public onlyOwner
        {
            //goerliOptimism chainId = 420.///
            //require(msg.sender == owner || msg.sender == worldId, "worldIdSetter not permitted.");
            require(block.chainid == 5 || block.chainid == 420, "wolrdId not available on this blockchain.");
            isWorldIdSet = true;
        }

        function getChainId() public view returns(uint256)
        {
            return block.chainid;
        }
    */

    /////"aaRelatedFunctions"//////////////////////////////////////////////////////////////////////////////
    
    function getAbstractedAccountAddress() public view returns(address)
    {
        return address(this);
    }

    function setCrossChainAa(address paramCorssChainAa) public
    {
        crossChainAaAddress = paramCorssChainAa;
    }

    function setUsdTokenAddress(address paramUsdTokenAddress) public
    {
        usdTokenAddress = paramUsdTokenAddress;
    }

    /////"layerZeroIntegrationRelatedFunctions"////////////////////////////////////////////////////////////    

    function _nonblockingLzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) internal override 
    {
        //bytes memory constructedPayload = abi.encode(msg.sender, paramNumberToTransfer);
        //(_tokenAddressPlaceHolder, _quantityToTransferPlaceHolder) = abi.decode(_payload, (address, uint));

        (address addressToTransfer, uint256 quantityToTransfer) = abi.decode(_payload, (address, uint256));
        /*
            uint256 actualAddressBalance = _balances[addressToTransfer];
            uint256 newAddressBalance = actualAddressBalance + quantityToTransfer;
            _balances[addressToTransfer] = newAddressBalance;
        */


        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////<

        iLzErc20(usdTokenAddress).transfer(addressToTransfer, quantityToTransfer);
    }





    function estimateFee(uint16 _dstChainId, bytes calldata _payload, bool _useZro, bytes calldata _adapterParams) public view returns (uint nativeFee, uint zroFee) 
    {
        return lzEndpoint.estimateFees(_dstChainId, address(this), _payload, _useZro, _adapterParams);
    }

    //IF NOT SUCCESFULL, USING A WRAPPER THAT CALLS THIS FUNCTION WITH THE VALUE OF 1 ETHER///
    function chainAbstractionTransferFunction(address paramDestinationAddressToTransfer, uint256 paramQuantityToTransferFromSourceAddress, uint256 paramQuantityToTransferFromDestinationAddress, uint16 _dstChainId) public payable 
    {
        //bytes memory constructedPayloadSource = abi.encode(paramDestinationAddressToTransfer, paramQuantityToTransferFromSourceAddress);
        bytes memory constructedPayloadDestination = abi.encode(paramDestinationAddressToTransfer, paramQuantityToTransferFromDestinationAddress);

        uint16 valueOne = 1;
        uint256 valueTwo = 200000;
        bytes memory adapterParams = abi.encodePacked(valueOne, valueTwo);

        uint etherToSend = 0.5 ether;



        _lzSend(_dstChainId, constructedPayloadDestination, payable(tx.origin), address(0x0), adapterParams, etherToSend);
        iLzErc20(usdTokenAddress).layerZeroTransfer{value: etherToSend}(paramDestinationAddressToTransfer, paramQuantityToTransferFromSourceAddress, _dstChainId);
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

    /////"nftRelatedFunctions"/////////////////////////////////////////////////////////////////////////////
    
    function getNftName(address paramNftAddress) public view returns(string memory)
    {
        return iNft(paramNftAddress).name();
    }

    function mintNft(address paramNftAddress) public
    {
        iNft(paramNftAddress).Mint();
    }

    function transferNft(address paramNftAddress, address paramTo, uint256 paramNftId) public
    {
        iNft(paramNftAddress).safeTransferFrom(address(this), paramTo, paramNftId);
    }

    function approveNft(address paramNftAddress, address paramNftTo, uint256 paramTokenId) public
    {
        iNft(paramNftAddress).approve(paramNftTo, paramTokenId);
    }

    function balanceOfAbstractedAccount(address paramNftAddress) public view returns(uint256)
    {
        iNft(paramNftAddress).balanceOf(address(this));
    }

    function checkOwnerOf(address paramNftAddress, uint256 paramNftId) public view returns(address)
    {
        iNft(paramNftAddress).ownerOf(paramNftId);
    }

    function nftTotalSupply(address paramNftAddress) public view returns(uint256)
    {
        iNft(paramNftAddress).totalSupply();
    }

    /////"lzErc20RelatedFunctions"/////////////////////////////////////////////////////////////////////////

    function getLzErc20Name(address paramLzErc20Address) public view returns(string memory)
    {
        return iLzErc20(paramLzErc20Address).name();
    }

    function mintLzErc20Tokens(address paramLzErc20Address, uint256 paramAmount) public
    {
        iLzErc20(paramLzErc20Address).mint(address(this), paramAmount);
    }

    function lzCrossChainTransfer(address paramLzErc20Address, address paramDestinationAddressToTransfer, uint256 paramQuantityToTransfer, uint16 _dstChainId) public payable
    {
        //function send(uint16 _dstChainId, bytes calldata _destination, bytes calldata _payload, address payable _refundAddress, address _zroPaymentAddress, bytes calldata _adapterParams) external payable;
        //lzEndpoint.send{value: _nativeFee}(_dstChainId, trustedRemote, _payload, _refundAddress, _zroPaymentAddress, _adapterParams);

        iLzErc20(paramLzErc20Address).layerZeroTransfer{value: msg.value}(paramDestinationAddressToTransfer, paramQuantityToTransfer, _dstChainId);
    }

    function lzNormalTransfer(address paramLzErc20Address, address paramTo, uint256 paramAmount) public
    {
        iLzErc20(paramLzErc20Address).transfer(paramTo, paramAmount);
    }

    function lzTransferFrom(address paramLzErc20Address, address paramTo, uint256 paramAmount) public
    {
        iLzErc20(paramLzErc20Address).transferFrom(address(this), paramTo, paramAmount);
    }

    function balanceOfLzErc20Tokens(address paramLzErc20Address, address paramAccount) public view returns(uint256)
    {
        return iLzErc20(paramLzErc20Address).balanceOf(paramAccount);
    }

    function totalSupplyLzErc20(address paramLzErc20Address) public view returns(uint256)
    {
        return iLzErc20(paramLzErc20Address).totalSupply();
    }
}
