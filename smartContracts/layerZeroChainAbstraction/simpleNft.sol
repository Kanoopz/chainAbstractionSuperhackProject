// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract simpleNft is ERC721, Ownable
{
    modifier onlyAccounts() 
    {
        require(msg.sender == tx.origin, "Not allowed origin");
        _;
    }



    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;


    constructor() ERC721("simpleNft", "sNft")
    {}


    function Mint() external payable onlyAccounts 
    {
        mintInternal();
    }

    function mintInternal() internal
    {
        _tokenIds.increment();

        uint256 tokenId = _tokenIds.current();
        _safeMint(msg.sender, tokenId);
    }

    function totalSupply() public view returns (uint256) 
    {
        return _tokenIds.current();
    }
}
