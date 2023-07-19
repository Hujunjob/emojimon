pragma solidity ^0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import {Movable,Player,MapConfig,OwnedBy, Position,Monster,Encounterable,MonsterCatchAttempt,EncounterData,Encounter,EncounterTrigger,Obstruction} from "../codegen/Tables.sol";
import {MonsterType,MonsterCatchResult} from "../codegen/Types.sol";
import {addressToEntityKey} from "../addressToEntityKey.sol";
import {positionToEntityKey} from "../positionToEntityKey.sol";

contract EncounterSystem is System{
    function throwBall() public{
        bytes32 player = addressToEntityKey(_msgSender());

        EncounterData memory encounter =  Encounter.get(player);
        require(encounter.exists,"not in encounter");

        uint256 rand = uint256(keccak256(abi.encode(player,encounter.catchAttempts,block.difficulty,encounter.monster)));
        if(rand%2==0){
            //catched
            MonsterCatchAttempt.emitEphemeral(player,MonsterCatchResult.Caught);
            OwnedBy.set(encounter.monster,player);
            Encounter.deleteRecord(player);
            Monster.deleteRecord(encounter.monster);
        }else if(encounter.catchAttempts>=2){
            //missed too many times, monster fled
            MonsterCatchAttempt.emitEphemeral(player,MonsterCatchResult.Fled);
            Encounter.deleteRecord(player);
            Monster.deleteRecord(encounter.monster);
        }else{
            //missed
            MonsterCatchAttempt.emitEphemeral(player,MonsterCatchResult.Missed);
            Encounter.setCatchAttempts(player,encounter.catchAttempts+1);
        }
    }

    function flee() public{
        bytes32 player = addressToEntityKey(_msgSender());

        EncounterData memory encounter =  Encounter.get(player);
        require(encounter.exists,"not in encounter");

        Monster.deleteRecord(encounter.monster);
        Encounter.deleteRecord(player);
    }
}