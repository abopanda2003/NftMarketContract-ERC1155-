// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./common/UmblCoreDataObjects.sol";
import "./common/UmblCoreEvents.sol";
import "./UmblCore.sol";

contract UmblMarketPlace is UmblCoreDataObjects, UmblCoreEvents, Ownable, ReentrancyGuard {

    using SafeMath for uint8;
    using SafeMath for uint256;
    using Strings for string;

    // Contract name
    string public name = "Umbrella MarketPlace";

    // Contract symbol
    string public symbol = "UmblMarket";
    
    ERC20 busdContract = ERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);

    UmblCore public umblCore;
    
    // Flag for main functions
    bool public isMarketPlaceFlag = false;

    constructor(UmblCore _umblCore) {
        umblCore = _umblCore;        
    }

    /**
    * @dev Buy crate
    * @param _id          Crate ID to mint
    */
    function buyCrate(
        uint256 _id
    ) external payable {
        
        require(isMarketPlaceFlag == true, "UmblMarketPlace#buyCrate: MARKETPLACE_DISABLED");
        
        require(msg.sender != owner(), "UmblMarketPlace#buyCrate: INVALID_ADDRESS");

        // check _crateId
        require(_id <= uint256(umblCore.nextCrateId()), "UmblMarketPlace#buyCrate: NONEXISTENT_CRATE");

        (, , uint8 crateFaction, uint8[] memory crateRarities, uint8 crateTokenCount, uint256 cratePrice, bool crateIsDeleted) = umblCore.getCrate(_id);
        
        require(crateIsDeleted == false, "UmblMarketPlace#buyCrate: DELETED_CRATE");
        
        // pay with BUSD for the crate price
        address payable ownerAddress = payable(owner());
        
        // check price
        require(busdContract.balanceOf(msg.sender) >= cratePrice, "UmblMarketPlace#buyCrate: NOENOUGH_BALANCE");
        
        uint256 allowance = busdContract.allowance(msg.sender, address(this));
        require(allowance >= cratePrice, "UmblMarketPlace#buyCrate: INVALID_ALLOWANCE");
        require(busdContract.transferFrom(msg.sender, ownerAddress, cratePrice));

        emit UmblPaidForCrate(msg.sender, _id, msg.value);
        
        mintCrateTokens(msg.sender, _id, crateFaction, crateRarities, crateTokenCount);
    }
    
     /**
    * @dev Mint tokens in crate
    * @param _to            Address of the future owner of the token
    * @param _id            Crate ID to mint
    * @param _faction       uint8 Faction of crate
    * @param _rarities      uint8 array Rarities of crate
    * @param _tokenCount    uint8 Token count of crate
    */
    function mintCrateTokens(
        address         _to,
        uint256         _id,
        uint8           _faction,
        uint8[] memory  _rarities,
        uint8           _tokenCount
    ) private {
        // get available preset ids
        uint256 nextPresetId = uint256(umblCore.nextPresetId());
        uint[] memory presetArray = new uint[](nextPresetId);
        uint presetCount = 0;

        for(uint i=0; i<_rarities.length; i++) {
            for(uint j=1; j<=nextPresetId; j++) {
                (, uint8 tokenType, , uint8 presetFaction, , uint8 rarity, , , , bool presetIsDeleted) = umblCore.getPreset(j);
                
                if(tokenType == uint8(TokenType.OBJECT) && presetIsDeleted == false && 
                    rarity == _rarities[i] && presetFaction == _faction) 
                {
                    presetArray[presetCount++] = j;
                }
            }
        }
        
        // check presetCount
        require(presetCount >= _tokenCount, "UmblMarketPlace#mintCrate: NOENOUGH_MATCHED_PRESET");
        
        // Get random preset for the crate
        uint[] memory selectedPreset = new uint[](_tokenCount);                
        uint selectedPresetId = 0;
        uint nonce = 1;

        for(uint i=0; i<_tokenCount; i++) {
            while(true) {
                uint randomNumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce++))) % presetCount;
                bool isExist = false;
                for(uint j=0; j<selectedPresetId; j++) {
                    if(!isExist && randomNumber == selectedPreset[j]) {
                        isExist = true;
                        break;
                    }
                }
                if(!isExist) {
                    selectedPreset[selectedPresetId++] = randomNumber;
                    break;
                }
            }
        }
        
        // // mint tokens
        uint256[] memory mintTokenIds = new uint256[](_tokenCount);
        uint256[] memory mintTokenAmounts = new uint256[](_tokenCount);
    
        for(uint i=0; i<_tokenCount; i++) {
            mintTokenIds[i] = presetArray[selectedPreset[i]];
            mintTokenAmounts[i] = 1;
        }
        
        address[] memory mintAddress = new address[](1);
        mintAddress[0] = _to;
        umblCore.mintBatchPresets(mintAddress, mintTokenIds, mintTokenAmounts);
        
        emit UmblCrateMinted(_to, _id, mintTokenIds);
    }
    
    /**
    * @dev Set marketplace flag
    * @param _newState bool
    */
    function setMarketPlaceFlag(
        bool _newState
    ) public onlyOwner {
        
        isMarketPlaceFlag = _newState;
        
        emit UmblMarketPlaceFlagUpdated(owner(), isMarketPlaceFlag);
    }
}