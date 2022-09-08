//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RoboPunksNFT is ERC721, Ownable {
    uint256 public mintPrice;
    uint256 public totalSupply;
    uint256 public maxSupply;
    uint256 public maxPerWallet;
    bool public isPublicMintEnabled;
    string internal baseTokenUri;
    address payable withdrawWallet;
    mapping (address => uint256) walletMints;

    constructor() payable ERC721('RoboPunk', 'RP') {
        mintPrice = 0.02 ether;
        totalSupply = 0;
        maxSupply = 9999;
        maxPerWallet = 20;
        //withdrawWallet = 0x23Be2697B4b656460C550a61e04EfE388C609e99;
    }

    function setIsPublicMintEnable(bool isPublicMintEnabled_) external onlyOwner {
        isPublicMintEnabled = isPublicMintEnabled_;
    }
    
    function setBaseTokenUri(string calldata baseTokenUri_) external onlyOwner{
        baseTokenUri = baseTokenUri_;
    }

    function tokenURI(uint256 tokenID_) public view override returns (string memory) {
        require(_exists(tokenID_), 'token does not exist!');
        return string(abi.encodePacked(baseTokenUri, Strings.toString(tokenID_), ".json"));
    }

    function withdraw() external payable {
        (bool success, ) = withdrawWallet.call{value: address(this).balance}('');
        require(success, 'withdraw failed.');
    }

    function mint(uint256 quantity_) public payable{
        require(isPublicMintEnabled, 'public mint is not enabled!');
        require(msg.value >= mintPrice*quantity_, 'not enough value!');
        require(totalSupply + quantity_ <= maxSupply, 'sold out.');
        require(walletMints[msg.sender] + quantity_ <= maxPerWallet, 'exceed the max per wallet.');

        for (uint256 i = 0; i < quantity_; i++){
            uint256 newTokenID = totalSupply + 1;
            totalSupply ++;
            _safeMint(msg.sender, newTokenID);
        }
    }
}
