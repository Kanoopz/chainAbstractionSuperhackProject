# chainAbstractionSuperhackProject
A basic accountAbstractionImplementation thats able to link a users abstractedAccounts between multiple chains. 

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

multiChain accountAbstraction implementation.
One abstractedAccount at its originalChain is able to manipulate its linked otherChain abstractedAccount assets, example:

We have a user that has linkedAbstractedAccounts in polygon and optimism. He has 70 usdc on polygon aa and 50 in optimism.
He wants to send 100 usdc to an EOA on optimism, so what he does is he send the 70 he has on his polygon aa to the optimism EOA using multichainInfraestructure and at the same time invoques a transaction (invoques from the polygon aa) on the optimism aa to send the remaining 30 usdc. 

The end result of the balances of the users abstractedAccounts are:
- Polygon; 0
- Optimism; 20

And the optimism EOA has received 100 usdc without even knowing that transfer was done through a multiChain process.

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

The project is being built with solidity, reactJs and ethersJs stack on goerliEthereum, sepoliaEthereum, goerliOptimism, baseTestnet, zoraTestnet and modeTestnet thanks to chainlinkCcip, hyperlane and layerZero multiChain infraestructure.


![image](https://github.com/Kanoopz/chainAbstractionSuperhackProject/assets/43384993/58665289-7e2e-4ecd-ae24-74f4432c24fb)



  
  


