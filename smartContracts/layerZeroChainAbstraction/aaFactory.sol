//SPDX-License-Identifier: MIT

import { abstractedAccount } from './abstractedAccount.sol';

pragma solidity 0.8.10;

contract aaFactory
{
    ////////////////////////////////////////////////////////////////////////////
    /////"generalVariables"/////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////// 
    mapping(address => uint) public ownerAaCounter;
    mapping(address => address[]) public ownerAccounts;
    mapping(address => address) public aaOwner;


    mapping(address => abstractedAccount) public aaContractInstances;

    /*
        bool public worldIdPermitted;
        IWorldID internal worldId;
        uint256 internal externalNullifier;
        uint256 internal immutable groupId = 1;
    */

   ////////////////////////////////////////////////////////////////////////////
   /////"functions"////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////////////////////  
   constructor()
   {}

   function createAa(address _lzEndpoint, address srcChainUsdTokenAddress) public returns(address)
   {
        //address paramOwner, address paramFactoryAddress, address _lzEndpoint, address srcChainUsdTokenAddress

       abstractedAccount newAccount = new abstractedAccount(msg.sender, address(this), _lzEndpoint, srcChainUsdTokenAddress);
       address newAccountAddress = newAccount.getAbstractedAccountAddress();
       uint counterWithAccountCreated = ownerAaCounter[msg.sender] + 1;

       ownerAaCounter[msg.sender] = counterWithAccountCreated;
       ownerAccounts[msg.sender].push(newAccountAddress);
       aaOwner[newAccountAddress] = msg.sender;



       aaContractInstances[newAccountAddress] = newAccount;


       return newAccountAddress;
   }

   /*
    function createAaWithWorldId()
    {}
   */
   
   function getUserAccountByIndex(address paramUserAddress, uint paramIndex) public view returns(address)
   {
       return ownerAccounts[paramUserAddress][paramIndex];
   }






   ////////////////////////////////////////////////////////////////////////////
   /////"aaInstancesRelatedFunctions"///////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////////////////////
   function aaInstanceGetName(address paramAaInstanceAddress, address paramNftAddress) public view returns(string memory)
    {
        return aaContractInstances[paramAaInstanceAddress].getNftName(paramNftAddress);
    }

    function aaInstanceMintNft(address paramAaInstanceAddress, address paramNftAddress) public
    {
        aaContractInstances[paramAaInstanceAddress].mintNft(paramNftAddress);
    }

    function aaInstancetransferNft(address paramAaInstanceAddress, address paramNftAddress, address paramTo, uint256 paramNftId) public
    {
        aaContractInstances[paramAaInstanceAddress].transferNft(paramNftAddress, paramTo, paramNftId);
    }

    function aaInstanceApproveNft(address paramAaInstanceAddress, address paramNftAddress, address paramNftTo, uint256 paramTokenId) public
    {
        aaContractInstances[paramAaInstanceAddress].approveNft(paramNftAddress, paramNftTo, paramTokenId);
    }

    function aaInstanceBalanceOfAbstractedAccount(address paramAaInstanceAddress, address paramNftAddress) public view returns(uint256)
    {
        aaContractInstances[paramAaInstanceAddress].balanceOfAbstractedAccount(paramNftAddress);
    }

    function aaInstanceCheckOwnerOf(address paramAaInstanceAddress, address paramNftAddress, uint256 paramNftId) public view returns(address)
    {
        aaContractInstances[paramAaInstanceAddress].checkOwnerOf(paramNftAddress, paramNftId);
    }

    function aaInstanceNftTotalSupply(address paramAaInstanceAddress, address paramNftAddress) public view returns(uint256)
    {
        aaContractInstances[paramAaInstanceAddress].nftTotalSupply(paramNftAddress);
    }  
}
