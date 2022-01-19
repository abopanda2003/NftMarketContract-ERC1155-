// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract UmblCoreEvents {

    using SafeMath for uint256;

    event UmblPresetCreated (
        address owner,
        uint256 id
    );

    event UmblPresetUpdated (
        address owner,
        uint256 id
    );

    event UmblPresetDeleted (
        address owner,
        uint256 id
    );

    event UmblCrateCreated (
        address owner,
        uint256 id
    );

    event UmblCrateUpdated (
        address owner,
        uint256 id
    );

    event UmblCrateDeleted (
        address owner,
        uint256 id
    );

    event UmblPackageCreated (
        address owner,
        uint256 id
    );

    event UmblPackageUpdated (
        address owner,
        uint256 id
    );

    event UmblPackageDeleted (
        address owner,
        uint256 id
    );

    event UmblTokenDataUpdated (
        address owner,
        uint256 id,
        address newOwner,
        uint8   newState,
        uint8   newHealth,
        uint256 newPrice,
        bool    newIsSale
    );

    event UmblMarketPlaceContractUpdated (
        address owner,
        address marketPlaceContract
    );

    event UmblCrateMinted (
        address owner,
        uint256 id,
        uint256[] tokenIds 
    );

    event UmblPackageMinted (
        address owner,
        uint256 id,
        uint256[] tokenIds 
    );

    event UmblPresetMinted (
        address owner,
        address[] to,
        uint256[] presetIds,
        uint256[] tokenIds,
        uint256[] amount
    );
    
    event UmblPaidForCrate (
        address owner,
        uint256 id,
        uint256 price
    );

    event UmblResaleFlagUpdated (
        address owner,
        bool isResaleFlag
    );
    
    event UmblMarketPlaceFlagUpdated (
        address owner,
        bool    isMarketPlaceFlag
    );

    event UmblTokenListAssigned (
        address owner,
        address[] to,
        uint256[][] ids
    );
}