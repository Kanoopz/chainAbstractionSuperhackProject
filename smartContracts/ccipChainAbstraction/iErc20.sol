//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface iErc20
{
    function drip(address to) external;
    function transfer(address to, uint256 amount) external returns(bool);
}
