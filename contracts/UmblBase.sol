// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./common/UmblCoreEvents.sol";
import "./common/UmblCoreDataStorages.sol";

/**
 * @title UmblBase
 * UmblBase - a contract for Umbl Core Basement.
 */

contract UmblBase is UmblCoreDataStorages, UmblCoreEvents, Ownable, ReentrancyGuard {

    using SafeMath for uint8;
    using SafeMath for uint256;
    using Strings for string;

    uint256 constant PRESET_MAX_LEVEL_VALUE     = 100;
    uint256 constant CRATE_MAX_RARITY_LENGTH    = 10;
    uint256 constant CRATE_MAX_TOKEN_COUNT      = 100;
    uint256 constant PACKAGE_MAX_PRESET_COUNT   = 100;
    
    /**
    * @dev Add and update UMBLPRESET item
    * @param _id uint256 ID of preset (when creating, it's value is zero)
    * @param _tokenType uint8 type of preset (CHARACTER, OBJECT, BADGE, ZONE)
    * @param _level uint8 level of preset (1 ~ 6)
    * @param _faction uint8 faction (SURVIVORS, SCIENTISTS)
    * @param _category uint8 category (WEAPONS, ARMOR, ACCESORIES, VIRUSES_BACTERIA, PARASITES_FUNGUS, VIRUS_VARIANTS)
    * @param _rarity uint8 rarity (COMMON, UNCOMMON, UNIQUE, RARE, EPIC, LEGENDARY, MYTHICAL)
    * @param _badgeType uint8 badgeType (BRONZE, SILVER, GOLD, DIAMOND, BLACK_DIAMOND)
    * @param _zoneType uint8 zoneType (S1, S1b, S2, S2b, S3, S4, S5, S6)
    * @param _price uint256 price
    */
    function makePreset(
        uint256 _id,
        uint8   _tokenType,
        uint8   _level,          
        uint8   _faction,
        uint8   _category,
        uint8   _rarity,
        uint8   _badgeType,
        uint8   _zoneType,
        uint256 _price
    ) public onlyOwner nonReentrant {

        bool isCreation;
        uint256 presetId;

        // check token type in preset
        require(_tokenType <= uint8(TokenType.ZONE), "UMBLBASE#makePreset: INVALID_TOKENTYPE");
        // check level
        require(_level <= PRESET_MAX_LEVEL_VALUE, "UMBLBASE#makePreset: INVALID_LEVEL_VALUE");
        // check faction
        require(_faction <= uint8(Faction.SCIENTISTS), "UMBLBASE#makePreset: INVALID_FACTION");
        // check category
        require(_category <= uint8(Category.VIRUS_VARIANTS), "UMBLBASE#makePreset: INVALID_CATEGORY");
        // check rarity
        require(_rarity <= uint8(Rarity.MYTHICAL), "UMBLBASE#makePreset: INVALID_RARITY");
        // check badgeType
        require(_badgeType <= uint8(Badge.BLACK_DIAMOND), "UMBLBASE#makePreset: INVALID_BADGETYPE");
        // check zoneType
        require(_zoneType <= uint8(Zone.S6), "UMBLBASE#makePreset: INVALID_ZONETYPE");
        // check price
        require(_price > 0, "UMBLBASE#makePreset: INVALID_PRICE");

        if(_id == 0) { // creation of new preset
            nextPresetId++;
            presetId = nextPresetId;
            isCreation = true;
        } else {
            require(_id <= nextPresetId, "UMBLBASE#makePreset: NONEXISTENT_PRESET");
            presetId = _id;
            isCreation = false;
        }

        UmblPreset memory newPresetData = UmblPreset(
            presetId,
            _tokenType,
            _level,
            _faction,
            _category,
            _rarity,
            _badgeType,
            _zoneType,
            _price,
            false                    
        );

        presetUmblData[presetId] = newPresetData;

        if(isCreation) {
            emit UmblPresetCreated(msg.sender, presetId);
        } else {
            emit UmblPresetUpdated(msg.sender, presetId);
        }
    }

    /**
    * @dev Delete UMBLPRESET item
    * @param _id uint256 ID of preset
    */
    function deletePreset(
        uint256 _id
    ) public onlyOwner nonReentrant {

        require(_id <= nextPresetId, "UMBLBASE#deletePreset: NONEXISTENT_PRESET");

        UmblPreset memory presetData = presetUmblData[_id];

        presetData.isDeleted = true;

        presetUmblData[_id] = presetData;

        emit UmblPresetDeleted(msg.sender, _id);
    }

    /**
    * @dev Get UMBLPRESET item
    * @param _id uint256 ID of preset
    */
    function getPreset(
        uint256 _id
    ) public view returns (
        uint256     id,
        uint8       tokenType,
        uint8       level,
        uint8       faction,
        uint8       category,
        uint8       rarity,
        uint8       badgeType,
        uint8       zoneType,
        uint256     price,
        bool        isDeleted
    ) {

        require(_id <= nextPresetId, "UMBLBASE#getPreset: NONEXISTENT_PRESET");

        UmblPreset memory presetData = presetUmblData[_id];

        return (
            presetData.id,
            presetData.tokenType,
            presetData.level,
            presetData.faction,
            presetData.category,
            presetData.rarity,
            presetData.badgeType,
            presetData.zoneType,
            presetData.price,
            presetData.isDeleted
        );
    }

    /**
    * @dev Add and update UMBLCRATE item
    * @param _id uint256 ID of preset (when creating, it's value is zero)
    * @param _faction uint8 faction (SURVIVORS, SCIENTISTS)
    * @param _rarities uint8 array rarity (COMMON, UNCOMMON, UNIQUE, RARE, EPIC, LEGENDARY, MYTHICAL)
    * @param _tokenCount uint8 badgeType (BRONZE, SILVER, GOLD, DIAMOND, BLACK_DIAMOND)
    * @param _price uint256 price
    */
    function makeCrate(
        uint256         _id,  
        uint8           _level,
        uint8           _faction,
        uint8[] memory  _rarities,
        uint8           _tokenCount,
        uint256         _price
    ) public onlyOwner nonReentrant {

        uint i;
        bool isCreation;
        uint256 crateId;        

        // check faction
        require(_faction == uint8(Faction.SURVIVORS) || _faction == uint8(Faction.SCIENTISTS), "UMBLBASE#makeCrate: INVALID_FACTION");
        // check rarities length
        require(_rarities.length > 0 && _rarities.length <= CRATE_MAX_RARITY_LENGTH, "UMBLBASE#makeCrate: INVALID_RARITY_LENGTH");
        // check rarities item value
        for(i=0; i<_rarities.length; i++) require(_rarities[i] >= uint8(Rarity.COMMON) && _rarities[i] <= uint8(Rarity.MYTHICAL), "UMBLBASE#makeCrate: INVALID_RARITY_VALUE");
        // check token count in crate
        require(_tokenCount > 0 && _tokenCount <= CRATE_MAX_TOKEN_COUNT, "UMBLBASE#makeCrate: INVALID_TOKENCOUNT");
        // check price
        require(_price > 0, "UMBLBASE#makeCrate: INVALID_PRICE");

        if(_id == 0) { // creation of new crate
            nextCrateId++;
            crateId = nextCrateId;
            isCreation = true;
        } else {
            require(_id <= nextCrateId, "UMBLBASE#makeCrate: NONEXISTENT_CRATE");
            crateId = _id;
            isCreation = false;
        }

        UmblCrate memory newCrateData = UmblCrate(
            crateId,
            _level,
            _faction,
            new uint8[](0), 
            _tokenCount,
            _price,
            false                    
        );

        crateUmblData[crateId] = newCrateData;

        for(i=0; i<_rarities.length; i++) {
            crateUmblData[crateId].rarities.push(uint8(_rarities[i]));
        }

        if(isCreation) {
            emit UmblCrateCreated(msg.sender, crateId);
        } else {
            emit UmblCrateUpdated(msg.sender, crateId);
        }
    }

    /**
    * @dev Delete UMBLCRATE item
    * @param _id uint256 ID of crate
    */
    function deleteCrate(
        uint256 _id
    ) public onlyOwner nonReentrant {

        require(_id <= nextCrateId, "UMBLBASE#deleteCrate: NONEXISTENT_CRATE");

        UmblCrate memory crateData = crateUmblData[_id];

        crateData.isDeleted = true;

        crateUmblData[_id] = crateData;

        emit UmblCrateDeleted(msg.sender, _id);
    }

    /**
    * @dev Get UMBLCRATE item
    * @param _id uint256 ID of preset
    */
    function getCrate(
        uint256 _id
    ) public view returns (
        uint256         id,
        uint8           level,
        uint8           faction,
        uint8[] memory  rarities,   
        uint8           tokenCount,
        uint256         price,       
        bool            isDeleted
    ) {

        require(_id <= nextCrateId, "UMBLBASE#getCrate: NONEXISTENT_CRATE");

        UmblCrate memory crateData = crateUmblData[_id];

        uint8[] memory _rarities = new uint8[](crateData.rarities.length);

        for(uint i=0; i<crateData.rarities.length; i++) {
            _rarities[i] = crateData.rarities[i];
        }

        return (
            crateData.id,
            crateData.level,
            crateData.faction,
            _rarities,
            crateData.tokenCount,
            crateData.price,
            crateData.isDeleted
        );
    }

    /**
    * @dev Add and update UMBLPACKAGE item
    * @param _id uint256 ID of preset (when creating, it's value is zero)
    * @param _tokenCount uint8 token count
    * @param _presetIds uint256 array presetIds
    * @param _startTime uint256 starttime of package
    * @param _endTime uint256 endtime of package
    * @param _price uint256 price
    */
    function makePackage(
        uint256             _id,   
        uint8               _tokenCount,
        uint256[] memory    _presetIds,
        uint256             _startTime,
        uint256             _endTime,
        uint256             _price
    ) public onlyOwner nonReentrant {

        uint i;
        bool isCreation;
        uint256 packageId;        

        // check token count
        require(_tokenCount > 0 && _tokenCount <= 100, "UMBLBASE#makePackage: INVALID_TOKENCOUNT");
        // check preset length
        require(_presetIds.length > 0 && _presetIds.length <= PACKAGE_MAX_PRESET_COUNT, "UMBLBASE#makePackage: INVALID_PRESET_LENGTH");
        // check rarities item value
        for(i=0; i<_presetIds.length; i++) 
            require(_presetIds[i] > 0 && _presetIds[i] <= nextPresetId, "UMBLBASE#makePackage: INVALID_PRESET_VALUE");        
        // check price
        require(_startTime < _endTime, "UMBLBASE#makePackage: INVALID_DATETIME");
        // check price
        require(_price > 0, "UMBLBASE#makePackage: INVALID_PRICE");

        if(_id == 0) { // creation of new crate
            nextPackageId++;
            packageId = nextPackageId;
            isCreation = true;
        } else {
            require(_id <= nextPackageId, "UMBLBASE#makePackage: NONEXISTENT_PACKAGE");
            packageId = _id;
            isCreation = false;
        }

        UmblPackage memory newPackageData = UmblPackage(
            packageId,
            _tokenCount,
            new uint256[](0), 
            _startTime,
            _endTime,
            _price,
            false                    
        );

        packageUmblData[packageId] = newPackageData;

        for(i=0; i<_presetIds.length; i++) {
            packageUmblData[packageId].presetIds.push(_presetIds[i]);
        }

        if(isCreation) {
            emit UmblPackageCreated(msg.sender, packageId);
        } else {
            emit UmblPackageUpdated(msg.sender, packageId);
        }
    }

    /**
    * @dev Delete UMBLPACKAGE item
    * @param _id uint256 ID of package
    */
    function deletePackage(
        uint256 _id
    ) public onlyOwner nonReentrant {

        require(_id <= nextPackageId, "UMBLBASE#deletePackage: NONEXISTENT_PACKAGE");

        UmblPackage memory packageData = packageUmblData[_id];

        packageData.isDeleted = true;

        packageUmblData[_id] = packageData;

        emit UmblPackageDeleted(msg.sender, _id);
    }

    /**
    * @dev Get UMBLPACKAGE item
    * @param _id uint256 ID of package
    */
    function getPackage(
        uint256 _id
    ) public view returns (
        uint256             id,
        uint8               tokenCount,
        uint256[] memory    presetIds,   
        uint256             startTime,
        uint256             endTime,
        uint256             price,       
        bool                isDeleted
    ) {

        require(_id <= nextPackageId, "UMBLBASE#getPackage: NONEXISTENT_PACKAGE");

        UmblPackage memory packageData = packageUmblData[_id];

        uint256[] memory _presetIds = new uint256[](packageData.presetIds.length);

        for(uint i=0; i<packageData.presetIds.length; i++) {
            _presetIds[i] = packageData.presetIds[i];
        }

        return (
            packageData.id,
            packageData.tokenCount,
            _presetIds,
            packageData.startTime,
            packageData.endTime,
            packageData.price,
            packageData.isDeleted
        );
    }
}