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

The project is being built with solidity, reactJs and ethersJs stack on goerliEthereum, sepoliaEthereum, goerliOptimism, baseTestnet, zoraTestnet and modeTestnet thanks to chainlinkCcip and layerZero multiChain infraestructure.


![image](https://github.com/Kanoopz/chainAbstractionSuperhackProject/assets/43384993/58665289-7e2e-4ecd-ae24-74f4432c24fb)


ccipImplementation:
	Sepolia:
		- 0x0542718f7215b442dE75A5aC5e25E3c9d8E1Bf36
	goerliOp:
		- 0x93A8fE00B91829763A797E933686318e89401c46
layerZeroImplementationWithWorldId:
	goerliOp:
		- lzErc20:
			0x5154440E0c8711264F543A4431C8657fF44A7C40
		- abstractedAccount:
			0x82517de60761A2D843A39Ae1d499a8eA6a2D1C48
	goerliBase:
		- lzErc20:
			0x93A8fE00B91829763A797E933686318e89401c46
		- abstractedAccount:
			0x44bA2D56A98176533E14167Be30F3e6a8B721fb8
	modeTestnet:
		- lzErc20:
			0x93A8fE00B91829763A797E933686318e89401c46
		-abstractedAccount:
			0x44bA2D56A98176533E14167Be30F3e6a8B721fb8
	zoraTestnet:
		- lzErc20:
			0x39978200DF7Ff5C64E8d8E2CB3F2314226A0D557
		- abstractedaccount:
			0x82517de60761A2D843A39Ae1d499a8eA6a2D1C48



  
  


