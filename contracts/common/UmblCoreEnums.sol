// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UmblCoreEnums {
    
    enum TokenType { NONE, CHARACTER, OBJECT, BADGE, ZONE }

    enum State { NONE, ADMIN_OWNED, USER_OWNED, USER_EQUIPPED, USER_STAKED, BURNED }

    enum Faction { NONE, SURVIVORS, SCIENTISTS }

    enum Category { NONE, WEAPONS, ARMOR, ACCESORIES, VIRUSES_BACTERIA, PARASITES_FUNGUS, VIRUS_VARIANTS }

    enum Rarity { NONE, COMMON, UNCOMMON, UNIQUE, RARE, EPIC, LEGENDARY, MYTHICAL }

    enum Badge { NONE, BRONZE, SILVER, GOLD, DIAMOND, BLACK_DIAMOND }

    enum Zone { NONE, S1, S1b, S2, S2b, S3, S4, S5, S6 }

}