//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {ERC721A} from "erc721a/contracts/ERC721A.sol";

error MaxSupplyReached();
error AboveMaxMintPerWallet();

contract MyNft is ERC721A("My Nft", "NFT") {
    uint256 public constant MAX_SUPPLY = 6888;
    uint256 public constant MAX_PER_WALLET = 2;

    constructor() {
        mint(1);
    }

    mapping(address => uint256) public _amountMinted;

    string[7] public languages = [
        "Solidity",
        "JavaScript",
        "Python",
        "Rust",
        "C++",
        "Go",
        "Java"
    ];
    string[2] public level = ["Junior", "Senior"];

    struct Info {
        string name;
        string lang;
        string lev;
    }

    mapping(uint256 => Info) public _info;

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    function processMint(uint256 _tokenId)
        internal
        returns (
            string memory _name,
            string memory _lang,
            string memory _lev
        )
    {
        _name = string(abi.encodePacked("#", _toString(_tokenId)));
        _lang = languages[RNG(_tokenId, languages.length)];
        _lev = level[RNG(_tokenId, 2)];
        _info[_tokenId] = Info({name: _name, lang: _lang, lev: _lev});
    }

    function mint(uint256 _amount) public {
        uint256 _tokenId = _nextTokenId();
        if (_amountMinted[msg.sender] + _amount > MAX_PER_WALLET)
            revert AboveMaxMintPerWallet();
        if (_amount + totalSupply() > MAX_SUPPLY) revert MaxSupplyReached();
        _amountMinted[msg.sender] += _amount;
        uint256 i;
        for (; i < _amount; ) {
            processMint(_tokenId);
            unchecked {
                ++_tokenId;
                ++i;
            }
        }
        _mint(msg.sender, _amount);
    }

    function getImage(uint256 _tokenId)
        public
        view
        returns (string memory svg)
    {
        Info memory info = _info[_tokenId];
        svg = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg">',
                        '<rect  height="285" width="407" y="70" x="25" stroke="#B2A5A5" fill="#C97A86"/>',
                        '<text text-anchor="start" font-size="24" y="103" x="57.23259"  fill="#000000">',
                        info.name,
                        "</text>"
                        '<text    text-anchor="middle" font-size="24" y="173" x="157.07693" fill="#000000">',
                        info.lang,
                        "</text>"
                        '<text  text-anchor="start" font-size="24" y="338" x="362" stroke-width="0" fill="#000000">',
                        info.lev,
                        "</text>",
                        "</svg>"
                    )
                )
            )
        );
    }

    //Chainlink is a better solution to this
    function RNG(uint256 _num, uint256 _mod)
        private
        view
        returns (uint256 num)
    {
        num =
            uint256(
                keccak256(
                    abi.encodePacked(
                        msg.sender,
                        block.difficulty,
                        block.timestamp,
                        _num
                    )
                )
            ) %
            _mod;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        Info memory info = _info[tokenId];

        return
            string(
                abi.encodePacked(
                    "base64:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "',
                                info.name,
                                '", "description": "',
                                "A random generated on chain Nft of different programming language and dev level",
                                '", "image": "',
                                "data:image/svg+xml;base64, ",
                                getImage(tokenId),
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
