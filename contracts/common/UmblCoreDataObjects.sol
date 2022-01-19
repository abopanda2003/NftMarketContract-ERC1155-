// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../common/UmblCoreEnums.sol";

contract UmblCoreDataObjects is UmblCoreEnums {

    using SafeMath for uint8;
    using SafeMath for uint256;

    struct UmblToken {
        // token id of object
        uint256 id;
        // preset id of object
        uint256 presetId;
        // owner address
        address owner;
        // character level => (1 ~ 6)
        uint8 level;
        // token faction => SURVIVORS, SCIENTISTS
        uint8 faction;
        // token category => WEAPONS, ARMOR, ACCESORIES, VIRUSES_BACTERIA, PARASITES_FUNGUS, VIRUS_VARIANTS
        uint8 category;
        // token rarity
        uint8 rarity;
        // token state => ADMIN_OWNED, USER_OWNED, USER_EQUIPPED, USER_STAKED, BURNED, etc
        uint8 state;     
        // health value of the token (0 ~ 100)
        uint8 health;  
        // price of the token
        uint256 price;
        // sale flag
        bool isSale;
    }

    struct UmblCrate {
        // crate id
        uint256 id;
        // crate level
        uint8 level;
        // crate faction
        uint8 faction;
        // array of rarities for the crate             
        uint8[] rarities;
        // token count inside the crate         
        uint8 tokenCount;
        // price of the crate
        uint256 price;
        // crate object flag for enabling         
        bool isDeleted;
    }

    struct UmblPreset {
        // preset id
        uint256 id;
        // token type => CHARACTER, OBJECT, BADGE, ZONE
        uint8 tokenType;
        // preset level
        uint8 level;     
        // preset token faction
        uint8 faction;
        // preset token category
        uint8 category;
        // preset token rarity
        uint8 rarity;
        // preset badge type
        uint8 badgeType;
        // preset zone type
        uint8 zoneType;
        // preset price
        uint256 price;
        // preset object flag for enabling
        bool isDeleted;
    }    

    struct UmblPackage {
        // package id
        uint256 id; 
        // token count inside the package
        uint8 tokenCount;
        // array of preset ids for the package
        uint256[] presetIds;
        // start time of the package
        uint256 startTime;
        // end time of the package
        uint256 endTime;         
        // price of the package
        uint256 price;
        // package object flag for enabling
        bool isDeleted;
    }
}