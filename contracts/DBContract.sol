// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "./interfaces/IAlyxNFT.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract DBContract is OwnableUpgradeable {

    /**************************************************************************
     *****  Common fields  ****************************************************
     **************************************************************************/
    address immutable public USDT_TOKEN;
    address immutable public LYNK_TOKEN;
    address immutable public BP_TOKEN;
    address immutable public KEY_TOKEN;
    address immutable public STAKING;
    address immutable public USER_INFO;
    address immutable public ALYX_NFT;
    address immutable public STAKING_ALYX_NFT;
    address immutable public LISTED_ALYX_NFT;
    address immutable public MARKET;
    address public TEAM_ADDR;

    /**************************************************************************
     *****  AlynNFT fields  ***************************************************
     **************************************************************************/
    // mint price
    uint256 public mintPriceInAU;
    uint256 public mintPriceInUSDT;
    address public recipient;
    uint256 public maxMintPerDayPerAddress;
    string public baseTokenURI;
    uint256[][] public attributeLevelThreshold;
    uint256 public mintLimitPerDay;

    /**************************************************************************
     *****  Market fields  ****************************************************
     **************************************************************************/
    bool public enableTokenWl;
    address[] public acceptTokens;
    uint256 public sellingLevelLimit;

    constructor(address[] memory addr){
        USDT_TOKEN = addr[0];
        LYNK_TOKEN =addr[1];
        BP_TOKEN = addr[2];
        KEY_TOKEN =addr[3];
        STAKING = addr[4];
        ALYX_NFT = addr[5];
        STAKING_ALYX_NFT = addr[6];
        LISTED_ALYX_NFT = addr[7];
        MARKET = addr[8];
        USER_INFO = addr[9];
        TEAM_ADDR = addr[10];
    }

    function __BoosterToken_init() public initializer {
        __DBContract_init_unchained();
        __Ownable_init();
    }

    function __DBContract_init_unchained() public onlyInitializing {
    }


    /**************************************************************************
     *****  AlynNFT Manager  **************************************************
     **************************************************************************/
    function setMintPrice(uint256 _mintPriceInAU, uint256 _mintPriceInUSDT) external onlyOwner {
        mintPriceInAU = _mintPriceInAU;
        mintPriceInUSDT = _mintPriceInUSDT;
    }

    function setRecipient(address _recipient) external onlyOwner {
        recipient = _recipient;
    }

    function setMaxMintPerDayPerAddress(uint256 _maxMintPerDayPerAddress) external onlyOwner {
        maxMintPerDayPerAddress = _maxMintPerDayPerAddress;
    }

    function setBaseTokenURI(string calldata _baseTokenURI) external onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function setMintLimitPerDay(uint256 _mintLimitPerDay) external onlyOwner {
        mintLimitPerDay = _mintLimitPerDay;
    }

    /**
     * CA: [100, 500, 1000 ... ]
     */
    function setAttributeLevelThreshold(IAlyxNFT.Attribute _attr, uint256[] calldata _thresholds) external onlyOwner {
        delete attributeLevelThreshold[uint256(_attr)];
        for (uint256 index; index < _thresholds.length; index++) {
            if (index > 0) {
                require(_thresholds[index] > _thresholds[index - 1], 'DBContract: invalid thresholds.');
            }
            attributeLevelThreshold[uint256(_attr)][index] = _thresholds[index];
        }
    }

    /**************************************************************************
     *****  Market Manager  ***************************************************
     **************************************************************************/
    function setAcceptToken(address _acceptToken) external onlyOwner {
        uint256 wlLength = acceptTokens.length;
        for (uint256 index; index < wlLength; index++) {
            if (_acceptToken == acceptTokens[index]) return;
        }

        acceptTokens.push(_acceptToken);
    }

    function removeAcceptToken(uint256 _index) external onlyOwner {
        uint256 wlLength = acceptTokens.length;
        if (_index < acceptTokens.length - 1)
            acceptTokens[_index] = acceptTokens[wlLength - 1];
        acceptTokens.pop();
    }

    function setSellingLevelLimit(uint256 _sellingLevelLimit) external onlyOwner {
        sellingLevelLimit = _sellingLevelLimit;
    }


    /**************************************************************************
     *****  public view  ******************************************************
     **************************************************************************/
    function calcLevel(IAlyxNFT.Attribute _attr, uint256 _point) external view returns (uint256 level, uint256 overflow) {
        uint256 thresholdLength = attributeLevelThreshold[uint256(_attr)].length;
        for (uint256 index; index < thresholdLength; index++) {
            if (_point > attributeLevelThreshold[uint256(_attr)][index]) {
                level = index + 1;
                overflow = _point - attributeLevelThreshold[uint256(_attr)][index];
            } else {
                break;
            }
        }
        return (level, overflow);
    }

    function acceptTokenLength() external view returns (uint256) {
        return acceptTokens.length;
    }

    function isAcceptToken(address _token) external view returns (bool) {
        uint256 wlLength = acceptTokens.length;
        for (uint256 index; index < wlLength; index++) {
            if (_token == acceptTokens[index]) return true;
        }

        return false;
    }

}
