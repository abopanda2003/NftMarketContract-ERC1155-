// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./UmblBase.sol";

contract UmblCore is UmblBase, ERC1155 {

    using SafeMath for uint8;
    using SafeMath for uint256;
    using Strings for string;
    
    // Contract name
    string public name = "Umbrella Core";

    // Contract symbol
    string public symbol = "UmblCore";

    // Metadata URI     
    string private baseMetadataUri = "http://portal.umbrellaproject.localhost/metadata/";
    // string private baseMetadataUri = "https://portal.umbrellaproject.localhost/metadata/{id}.json";  

    // Marketplace contract address
    address public marketPlaceContract = address(0x0);

    // total supply mapping for each tokenId
    mapping (uint256 => uint256) public tokenSupply;

    // Flag for marketplace function (sell & resell)
    bool public isResaleFlag = false;

    /**
    * @dev Require msg.sender to be allowed marketplace contract
    */
    modifier marketAndOwnerOnly {
        require(marketPlaceContract != address(0x0), "UmblCore#marketOnly: MARKET_CONTRACT_NOTDEFINED");
        require(msg.sender == marketPlaceContract || msg.sender == owner(), "UmblCore#marketOnly: INVALID_ADDRESS");
        _;
    }

    constructor() ERC1155(baseMetadataUri) {
        
    }

    /**
    * @dev Set marketplace contract address
    * @param _to    Address of the marketplace contract
    */
    function setMarketPlaceContract(
        address _to
    ) external onlyOwner {

        require(_to != address(0x0), "UmblCore#setMarketPlaceContract: MARKET_CONTRACT_INVALID");

        marketPlaceContract = _to;

        emit UmblMarketPlaceContractUpdated(owner(), marketPlaceContract);
    }

    /**
    * @dev Mints tokens in crate
    * @param _to          Address of the future owner of the token
    * @param _id          Crate ID to mint
    */
    // function mintCrate(
    //     address _to,
    //     uint256 _id
    // ) external marketOnly {

    //     // check _crateId
    //     require(_id <= nextCrateId, "UmblCore#mintCrate: NONEXISTENT_CRATE");

    //     UmblCrate memory crateData = crateUmblData[_id];

    //     // check flag
    //     require(crateData.isDeleted == false, "UmblCore#mintCrate: DELETED_CRATE");

    //     // get available preset ids
    //     uint[] memory presetArray = new uint[](nextPresetId);
    //     uint presetCount = 0;

    //     for(uint i=0; i<crateData.rarities.length; i++) {

    //         for(uint j=1; j<=nextPresetId; j++) {  
    //             if(presetUmblData[j].tokenType == uint8(TokenType.OBJECT) && presetUmblData[j].isDeleted == false && 
    //                 presetUmblData[j].rarity == crateData.rarities[i] && presetUmblData[j].faction == crateData.faction) 
    //             {
    //                 presetArray[presetCount++] = j;
    //             }
    //         }
    //     }

    //     // check presetCount
    //     require(presetCount > 0, "UmblCore#mintCrate: NONMATCHED_PRESET");

    //     // Get random preset for the crate
    //     uint[] memory selectedPreset = new uint[](crateData.tokenCount);                
    //     uint selectedPresetId = 0;
    //     uint nonce = 1;

    //     for(uint i=0; i<crateData.tokenCount; i++) {
    //         while(true) {
    //             uint randomNumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce++))) % presetCount;
    //             bool isExist = false;
    //             for(uint j=0; j<selectedPresetId; j++) {
    //                 if(!isExist && randomNumber == selectedPreset[j]) {
    //                     isExist = true;
    //                     break;
    //                 }
    //             }
    //             if(!isExist) {
    //                 selectedPreset[selectedPresetId++] = randomNumber;
    //                 break;
    //             }
    //         }            
    //     }

    //     // mint tokens
    //     uint256[] memory mintedTokenIds = new uint256[](crateData.tokenCount);
    
    //     for(uint i=0; i<crateData.tokenCount; i++) {
    //         // get preset id
    //         uint presetId = presetArray[selectedPreset[i]];

    //         UmblPreset memory presetData = presetUmblData[presetId];
    //         uint256 tokenId = presetData.id;

    //         // mint token according to the tokenId and assign it to user
    //         _mint(_to, tokenId, 1, "");

    //         // increase total supply of the tokenId
    //         tokenSupply[tokenId] = tokenSupply[tokenId].add(1);

    //         // increase next token ID
    //         nextTokenId++;

    //         // create a new token struct and pass it new values
    //         UmblToken memory newUmblToken = UmblToken(
    //             nextTokenId,
    //             tokenId,
    //             _to,
    //             uint8(0),
    //             presetData.faction,
    //             presetData.category,
    //             presetData.rarity,
    //             uint8(State.USER_OWNED),
    //             uint8(100),
    //             presetData.price,
    //             false
    //         );

    //         mintedTokenIds[i] = nextTokenId;

    //         // add the token id and it's struct to all tokens mapping
    //         tokenUmblData[nextTokenId] = newUmblToken;
    //     }

    //     emit UmblCrateMinted(_to, _id, mintedTokenIds);
    // }

    /**
    * @dev Mints tokens in crate
    * @param _to          Address of the future owner of the token
    * @param _id          Crate ID to mint
    * @param _currentTime Current datetime value
    */
    // function mintPackage(
    //     address _to,
    //     uint256 _id,
    //     uint256 _currentTime
    // ) external marketOnly {

    //     // check _crateId
    //     require(_id <= nextPackageId, "UmblCore#mintPackage: NONEXISTENT_PACKAGE");

    //     UmblPackage memory packageData = packageUmblData[_id];

    //     // check flag
    //     require(packageData.isDeleted == false, "UmblCore#mintPackage: DELETED_PACKAGE");

    //     // check datetime
    //     require(packageData.startTime <= _currentTime && packageData.endTime >= _currentTime, "UmblCore#mintPackage: INVALID_DATETIME");

    //     // mint tokens
    //     uint256[] memory mintedTokenIds = new uint256[](packageData.tokenCount);

    //     for(uint i=0; i<packageData.tokenCount; i++) {
    //         // get preset id
    //         uint256 presetId = packageData.presetIds[i];

    //         UmblPreset memory presetData = presetUmblData[presetId];
    //         uint256 tokenId = presetData.id;

    //         // mint token according to the tokenId and assign it to user
    //         _mint(_to, tokenId, 1, "");

    //         // increase total supply of the tokenId
    //         tokenSupply[tokenId] = tokenSupply[tokenId].add(1);

    //         // increase next token ID
    //         nextTokenId++;

    //         // create a new token struct and pass it new values
    //         UmblToken memory newUmblToken = UmblToken(
    //             nextTokenId,
    //             tokenId,
    //             _to,
    //             uint8(0),
    //             presetData.faction,
    //             presetData.category,
    //             presetData.rarity,
    //             uint8(State.USER_OWNED),
    //             uint8(100),
    //             presetData.price,
    //             false
    //         );

    //         mintedTokenIds[i] = nextTokenId;

    //         // add the token id and it's struct to all tokens mapping
    //         tokenUmblData[nextTokenId] = newUmblToken;
    //     }

    //     emit UmblPackageMinted(_to, _id, mintedTokenIds);
    // }

    /**
    * @dev Mints tokens in Presets    
    * @param _to            address Address of the future owner of the tokens
    * @param _ids           uint256 array Preset IDs to mint
    * @param _amounts       uint256 array Token amounts to mint
    */
    function mintBatchPresets(
        address[] memory    _to,
        uint256[] memory    _ids,
        uint256[] memory    _amounts
    ) external marketAndOwnerOnly {
        
        require(msg.sender == marketPlaceContract || msg.sender == owner(), "UmblCore#mintBatchPresets: INVALID_ADDRESS");

        // check _to address
        for(uint i=0; i<_to.length; i++)
            require(_to[i] != address(0x0), "UmblCore#mintBatchPresets: INVALID_ADDRESS");

        // check _id
        for(uint i=0; i<_ids.length; i++)
            require(_ids[i] <= nextPresetId, "UmblCore#mintBatchPresets: NONEXISTENT_PRESET");
        
        // calculate amounts
        uint256 totalAmount = 0;
        for(uint i=0; i<_amounts.length; i++)
            totalAmount += _amounts[i];

        uint256[] memory mintedTokenIds = new uint256[](totalAmount * _to.length);
        uint256 mintedTokenIndex = 0;

        // mint tokens
        for(uint k=0; k<_to.length; k++) {
            for(uint i=0; i<_ids.length; i++) {
                // uint256 _id = _ids[i];
                // uint256 _amount = _amounts[i];

                UmblPreset memory presetData = presetUmblData[_ids[i]];
                // uint256 tokenId = presetData.id;

                // mint token according to the tokenId and assign it to user
                _mint(_to[k], presetData.id, _amounts[i], "");

                // increase total supply of the tokenId
                tokenSupply[presetData.id] = tokenSupply[presetData.id].add(_amounts[i]);

                uint8 tokenState = uint8(State.USER_OWNED);
                if(_to[k] == owner()) tokenState = uint8(State.ADMIN_OWNED);

                for(uint j=0; j<_amounts[i]; j++) {
                    // increase next token ID
                    nextTokenId++;

                    // create a new token struct and pass it new values
                    UmblToken memory newUmblToken = UmblToken(
                        nextTokenId,
                        presetData.id,
                        _to[k],
                        presetData.tokenType,
                        presetData.faction,
                        presetData.category,
                        presetData.rarity,
                        tokenState,
                        uint8(100),
                        presetData.price,
                        false
                    );

                    // add the token id and it's struct to all tokens mapping
                    tokenUmblData[nextTokenId] = newUmblToken;

                    mintedTokenIds[mintedTokenIndex++] = nextTokenId;
                }
            }
            
        }

        emit UmblPresetMinted(msg.sender, _to, _ids, mintedTokenIds, _amounts);
    }

    /**
    * @dev Get metadata uri
    * @param _id uint256 ID of token type
    */
    function uri(
        uint256 _id
    ) public override(ERC1155) view returns (string memory) {
        require(_id <= nextTokenId, "UmblCore#uri: NONEXISTENT_TOKEN");

        UmblToken memory umblTokenData = tokenUmblData[_id];

        require(_exists(umblTokenData.presetId), "UmblCore#uri: NONEXISTENT_TOKEN");

        return string(abi.encodePacked(
            baseMetadataUri,
            Strings.toString(_id)
        ));
    }

    /**
    * @dev Returns the total quantity for a token ID
    * @param _id uint256 ID of the token to query
    * @return amount of token in existence
    */
    function totalSupply(
        uint256 _id
    ) public view returns (uint256) {
        return tokenSupply[_id];
    }

    /**
    * @dev Will update the base URL of token's URI
    * @param _newBaseMetadataURI New base URL of token's URI
    */
    function setBaseMetadataURI(
        string memory _newBaseMetadataURI
    ) public onlyOwner {
        baseMetadataUri = _newBaseMetadataURI;
    }

    /**
    * @dev Returns whether the specified token exists by checking to see if it has a total supply
    * @param _id uint256 ID of the token to query the existence of
    * @return bool whether the token exists
    */
    function _exists(
        uint256 _id
    ) internal view returns (bool) {
        return tokenSupply[_id] != 0;
    }

    /**
    * @dev Set marketplace flag
    * @param _newState bool
    */
    function setResaleFlag(
        bool _newState
    ) public onlyOwner {
        
        isResaleFlag = _newState;
        
        emit UmblResaleFlagUpdated(owner(), isResaleFlag);
    }
    
    /**
    * @dev Update UMBLTOKEN item state
    * @param _id uint256 ID of token
    * @param _owner address new owner
    * @param _state uint8 new state
    * @param _health uint8 new health
    * @param _price uint256 new price
    * @param _isSale bool new flag for sale
    */
    function updateTokenData(
        uint256 _id,
        address _owner,
        uint8   _state,
        uint8   _health,
        uint256 _price,
        bool    _isSale
    ) external {
        require(_id <= nextTokenId, "UMBLBASE#updateTokenData: NONEXISTENT_TOKEN");

        // get the token from all UmblData mapping and create a memory of it as defined
        UmblToken memory umblToken = tokenUmblData[_id];
        
        require(msg.sender == owner() || msg.sender == umblToken.owner || msg.sender == marketPlaceContract, "UMBLBASE#updateTokenData: INVALID_PERMISSION");
        
        umblToken.owner     = _owner;
        umblToken.state     = _state;
        umblToken.health    = _health;
        umblToken.price     = _price;
        umblToken.isSale    = _isSale;

        // set and update that token in the mapping
        tokenUmblData[_id] = umblToken;

        emit UmblTokenDataUpdated(msg.sender, _id, _owner, _state, _health, _price, _isSale);
    }   
    
    /**
    * @dev Assign tokens in List   
    * @param _to            address Address of the future owner of the tokens
    * @param _ids           uint256 array token IDs to assign
    */
    function assignBatchToken(
        address[]   memory    _to,
        uint256[][] memory    _ids
    ) external onlyOwner {

        // check _to address
        for(uint i=0; i<_to.length; i++)
            require(_to[i] != address(0x0) && _to[i] != owner(), "UmblCore#assignBatchPresets: INVALID_ADDRESS");
            
        
        // check _id
        for(uint i=0; i<_ids.length; i++)
            for(uint j=0; j<_ids[i].length; j++)
                require(_ids[i][j] <= nextTokenId, "UmblCore#assignBatchPresets: NONEXISTENT_TOKEN");

        // assign tokens
        for(uint i=0; i<_ids.length; i++) {
            uint[] memory presetList = new uint[](_ids[i].length);
            uint[] memory amountList = new uint[](_ids[i].length);
            for(uint j=0; j<_ids[i].length; j++) {
                UmblToken memory tokenData = tokenUmblData[_ids[i][j]];
                
                presetList[j] = tokenData.presetId;
                amountList[j] = 1;
                
                tokenData.owner     = _to[i];
                tokenData.state     = uint8(State.USER_OWNED);
                
                tokenUmblData[_ids[i][j]] = tokenData;
            }
            safeBatchTransferFrom(owner(), _to[i], presetList, amountList, "");
        }

        emit UmblTokenListAssigned(msg.sender, _to, _ids);
    }
}