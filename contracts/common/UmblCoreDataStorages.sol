// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./UmblCoreDataObjects.sol";

contract UmblCoreDataStorages is UmblCoreDataObjects {

    using SafeMath for uint256;    

    // map token id to token data
    mapping(uint256 => UmblToken) public tokenUmblData;    

    // map preset id to preset data
    mapping(uint256 => UmblPreset) public presetUmblData;    

    // map crate id to crate data
    mapping(uint256 => UmblCrate) public crateUmblData;    

    // map package id to package data
    mapping(uint256 => UmblPackage) public packageUmblData;

    uint256 public nextTokenId = 0;
    uint256 public nextPresetId = 0;
    uint256 public nextCrateId = 0;    
    uint256 public nextPackageId = 0;
}