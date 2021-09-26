// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.7.0 <0.9.0;

import {DoomCultSocietyDAO} from '../doomCultSociety.sol';

contract DoomCultSocietyDAOTest is DoomCultSocietyDAO {
    constructor() DoomCultSocietyDAO() {}

    function forceAwake() public {
        isAwake = true;
    }

    function forceAdvanceEpoch() public {
        timestampUntilNextEpoch = 0;
    }

    function forceMaximumCultists() public {
        _totalSupply = NUM_STARTING_CULTISTS;
        _balances[msg.sender] = NUM_STARTING_CULTISTS;
    }

    function forceLargeSacrifice(uint256 num) public {
        currentEpochTotalSacrificed += num;
    }
}
