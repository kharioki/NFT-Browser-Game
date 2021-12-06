// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./libraries/Base64.sol";

import "hardhat/console.sol";

contract MyEpicGame is ERC721 {
    struct CharacterAttributes {
        uint256 characterIndex;
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }

    // the tokenId is the NFTs unique identifier e.g 0, 1, 2, 3
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    CharacterAttributes[] defaultCharacters;

    // create a mapping from the nft's tokenId => NFTs attributes
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    // mapping from an address => the NFTs tokenId - store the owner of NFT and reference it later
    mapping(address => uint256) public nftHolders;

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint256[] memory characterHP,
        uint256[] memory characterAttackDamage
    ) ERC721("Heroes", "HERO") {
        for (uint256 i = 0; i < characterNames.length; i++) {
            defaultCharacters.push(
                CharacterAttributes({
                    characterIndex: i,
                    name: characterNames[i],
                    imageURI: characterImageURIs[i],
                    hp: characterHP[i],
                    maxHp: characterHP[i],
                    attackDamage: characterAttackDamage[i]
                })
            );

            CharacterAttributes memory c = defaultCharacters[i];
            console.log(
                "done initializing geniuses %s w/ HP %s, img %s",
                c.name,
                c.hp,
                c.imageURI
            );
        }

        // increment tokenIds
        _tokenIds.increment();
    }

    // mint NFT
    function mintCharacterNFT(uint256 _characterIndex) external {
        // current tokenId
        uint256 newItemId = _tokenIds.current();

        // assign tokenIds to caller's wallet address
        _safeMint(msg.sender, newItemId);

        // map tokenId to NFT attributes
        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].maxHp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage
        });

        console.log(
            "minted NFT w/ tokenId %s and characterIndex %s",
            newItemId,
            _characterIndex
        );

        // see who owns NFT
        nftHolders[msg.sender] = newItemId;

        // increment tokenIds
        _tokenIds.increment();
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        CharacterAttributes memory charAttributes = nftHolderAttributes[
            _tokenId
        ];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(
            charAttributes.attackDamage
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        charAttributes.name,
                        " -- NFT #: ",
                        Strings.toString(_tokenId),
                        '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "',
                        charAttributes.imageURI,
                        '", "attributes": [ { "trait_type": "Health Points", "value": ',
                        strHp,
                        ', "max_value":',
                        strMaxHp,
                        '}, { "trait_type": "Attack Damage", "value": ',
                        strAttackDamage,
                        "} ]}"
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }
}
