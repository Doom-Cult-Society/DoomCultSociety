// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.7.0 <0.9.0;

import {DoomCultSocietyDAO} from '../doomCultSociety.sol';
import {DoomCultSociety} from '../doomCultSociety.sol';

contract DoomCultSocietyDAOTest is DoomCultSocietyDAO {
    constructor() DoomCultSocietyDAO() {}

    function forceAwake() public {
        isAwake = true;
    }

    function forceAdvanceEpoch() public {
        timestampUntilNextEpoch = 0;
    }

    function forceMaximumCultists() public {
        _totalSupply = MAX_CULTISTS;
        _balances[msg.sender] = MAX_CULTISTS;
    }

    function forceLargeSacrifice(uint256 num) public {
        currentEpochTotalSacrificed += num;
    }
}

contract DoomCultSocietyTest is DoomCultSociety {
    constructor() DoomCultSociety() {}

    function getImgString(uint256 tokenId) public pure returns (string memory) {
        return getImgData(tokenId);
    }
}
