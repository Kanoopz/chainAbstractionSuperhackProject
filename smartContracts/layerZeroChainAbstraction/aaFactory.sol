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


   ////////////////////////////////////////////////////////////////////////////
   /////"functions"////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////////////////////  
   constructor()
   {}

   function createAa(address _lzEndpoint, address srcChainUsdTokenAddress) public returns(address)
   {
       abstractedAccount newAccount = new abstractedAccount(msg.sender, address(this), _lzEndpoint, srcChainUsdTokenAddress);
       address newAccountAddress = newAccount.getAbstractedAccountAddress();
       uint counterWithAccountCreated = ownerAaCounter[msg.sender] + 1;

       ownerAaCounter[msg.sender] = counterWithAccountCreated;
       ownerAccounts[msg.sender].push(newAccountAddress);
       aaOwner[newAccountAddress] = msg.sender;



       aaContractInstances[newAccountAddress] = newAccount;


       return newAccountAddress;
   }
   
   function getUserAccountByIndex(address paramUserAddress, uint paramIndex) public view returns(address)
   {
       return ownerAccounts[paramUserAddress][paramIndex];
   }
}
