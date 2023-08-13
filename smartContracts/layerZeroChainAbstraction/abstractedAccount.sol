//SPDX-License-Identifier: MIT

import { IWorldID } from './interfaces/IWorldID.sol';
import { iNft } from './interfaces/iNft.sol';
import { iLzErc20 } from './interfaces/iLzErc20.sol';

import { ByteHasher } from "./helpers/ByteHasher.sol";
import { IWorldID } from "./interfaces/IWorldID.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import { NonblockingLzApp } from "../layerZeroSolidityIntegration/contracts/lzApp/NonblockingLzApp.sol";

pragma solidity 0.8.10;

contract abstractedAccount is NonblockingLzApp
{
    using ByteHasher for bytes;

    ////////////////////////////////////////////////////////////////////////////
    /////"generalVariables"/////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////// 
    address public factoryAddress;
    address public crossChainAaAddress;
    address public usdTokenAddress; 

    uint8 public nftCounter;
    uint8 public tokenCounter;

    address[] public nftAddresses;
    address[] public tokenAddresses;

    /////"worldcoinVariables"///////////////////////////////////////////////////
    error InvalidNullifier();

    IWorldID internal immutable worldId;
    uint256 internal immutable externalNullifier;
    uint256 internal immutable groupId = 0;

    mapping(uint256 => bool) internal nullifierHashes;

    uint public signalCounter = 0;
    uint256 public ownerNullifierHash;
    

    ////////////////////////////////////////////////////////////////////////////
    /////"functions"////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////  
    constructor(address paramFactoryAddress, address _lzEndpoint, address srcChainUsdTokenAddress, address _worldId, string memory _appId, string memory _actionId) NonblockingLzApp(_lzEndpoint)
    {
        factoryAddress = paramFactoryAddress;
        usdTokenAddress = srcChainUsdTokenAddress;

        IWorldID worldIdInstance = IWorldID(_worldId);
        
        worldId = worldIdInstance;
        externalNullifier = abi.encodePacked(abi.encodePacked(_appId).hashToField(), _actionId).hashToField();
    }


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

    /////"worldIdVersionOfImportantFunctions"/////////////////////////////////////////////////////////////////////////

    function setOwnerNullifierHash(string memory signal, uint256 root, uint256 nullifierHash, uint256[8] calldata proof) public
    {
        worldId.verifyProof(root, groupId, abi.encodePacked(signal).hashToField(), nullifierHash, externalNullifier, proof);

        ownerNullifierHash = nullifierHash;

        signalCounter++;
    }

    function useWorldIdForChainAbstractionTransferFunction(address paramDestinationAddressToTransfer, uint256 paramQuantityToTransferFromSourceAddress, uint256 paramQuantityToTransferFromDestinationAddress, uint16 _dstChainId, string memory signal, uint256 root, uint256 nullifierHash, uint256[8] calldata proof) public payable
    {
        worldId.verifyProof(root, groupId, abi.encodePacked(signal).hashToField(), nullifierHash, externalNullifier, proof);
        signalCounter++;

        bytes memory constructedPayloadDestination = abi.encode(paramDestinationAddressToTransfer, paramQuantityToTransferFromDestinationAddress);

        uint16 valueOne = 1;
        uint256 valueTwo = 200000;
        bytes memory adapterParams = abi.encodePacked(valueOne, valueTwo);

        uint etherToSend = 0.5 ether;


        _lzSend(_dstChainId, constructedPayloadDestination, payable(tx.origin), address(0x0), adapterParams, etherToSend);
        iLzErc20(usdTokenAddress).layerZeroTransfer{value: etherToSend}(paramDestinationAddressToTransfer, paramQuantityToTransferFromSourceAddress, _dstChainId);
    }


    function useWorldIdFoTransferNft(address paramNftAddress, address paramTo, uint256 paramNftId, string memory signal, uint256 root, uint256 nullifierHash, uint256[8] calldata proof) public
    {
        worldId.verifyProof(root, groupId, abi.encodePacked(signal).hashToField(), nullifierHash, externalNullifier, proof);
        signalCounter++;

        iNft(paramNftAddress).safeTransferFrom(address(this), paramTo, paramNftId);
    }


    function useWorldIdForLzCrossChainTransfer(address paramLzErc20Address, address paramDestinationAddressToTransfer, uint256 paramQuantityToTransfer, uint16 _dstChainId, string memory signal, uint256 root, uint256 nullifierHash, uint256[8] calldata proof) public payable
    {
        worldId.verifyProof(root, groupId, abi.encodePacked(signal).hashToField(), nullifierHash, externalNullifier, proof);
        signalCounter++;

        iLzErc20(paramLzErc20Address).layerZeroTransfer{value: msg.value}(paramDestinationAddressToTransfer, paramQuantityToTransfer, _dstChainId);
    }


    function useWorldIdForfunctionLzNormalTransfer(address paramLzErc20Address, address paramTo, uint256 paramAmount, string memory signal, uint256 root, uint256 nullifierHash, uint256[8] calldata proof) public
    {
        iLzErc20(paramLzErc20Address).transfer(paramTo, paramAmount);

        worldId.verifyProof(root, groupId, abi.encodePacked(signal).hashToField(), nullifierHash, externalNullifier, proof);
        signalCounter++;
    }


    function getStringSignalCounter() public view returns(string memory)
    {
        string memory stringSignal = Strings.toString(signalCounter);

        return stringSignal;
    }


    /////"layerZeroIntegrationRelatedFunctions"////////////////////////////////////////////////////////////    

    function _nonblockingLzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) internal override 
    {
        (address addressToTransfer, uint256 quantityToTransfer) = abi.decode(_payload, (address, uint256));

        iLzErc20(usdTokenAddress).transfer(addressToTransfer, quantityToTransfer);
    }


    function estimateFee(uint16 _dstChainId, bytes calldata _payload, bool _useZro, bytes calldata _adapterParams) public view returns (uint nativeFee, uint zroFee) 
    {
        return lzEndpoint.estimateFees(_dstChainId, address(this), _payload, _useZro, _adapterParams);
    }


    function chainAbstractionTransferFunction(address paramDestinationAddressToTransfer, uint256 paramQuantityToTransferFromSourceAddress, uint256 paramQuantityToTransferFromDestinationAddress, uint16 _dstChainId) public payable 
    {
        bytes memory constructedPayloadDestination = abi.encode(paramDestinationAddressToTransfer, paramQuantityToTransferFromDestinationAddress);

        uint16 valueOne = 1;
        uint256 valueTwo = 200000;
        bytes memory adapterParams = abi.encodePacked(valueOne, valueTwo);

        uint etherToSend = 0.5 ether;


        _lzSend(_dstChainId, constructedPayloadDestination, payable(tx.origin), address(0x0), adapterParams, etherToSend);
        iLzErc20(usdTokenAddress).layerZeroTransfer{value: etherToSend}(paramDestinationAddressToTransfer, paramQuantityToTransferFromSourceAddress, _dstChainId);
    }


    function setOracle(uint16 dstChainId, address oracle) external onlyOwner 
    {
        uint TYPE_ORACLE = 6;
        // set the Oracle
        lzEndpoint.setConfig(lzEndpoint.getSendVersion(address(this)), dstChainId, TYPE_ORACLE, abi.encode(oracle));
    }

    function getOracle(uint16 remoteChainId) external view returns (address _oracle) 
    {
        bytes memory bytesOracle = lzEndpoint.getConfig(lzEndpoint.getSendVersion(address(this)), remoteChainId, address(this), 6);
        assembly 
        {
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
