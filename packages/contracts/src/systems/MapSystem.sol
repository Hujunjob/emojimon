// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { System } from "@latticexyz/world/src/System.sol";
import {Movable,Player,MapConfig, Position,Monster,Encounterable,EncounterData,Encounter,EncounterTrigger,Obstruction} from "../codegen/Tables.sol";
import {MonsterType} from "../codegen/Types.sol";
import {addressToEntityKey} from "../addressToEntityKey.sol";
import {positionToEntityKey} from "../positionToEntityKey.sol";
 
contract MapSystem is System {
  modifier CheckObstruction(uint32 x,uint32 y){
    bytes32 positionId = positionToEntityKey(x, y);
    require(!Obstruction.get(positionId),"is obstruction");
    _;
  }
  function distance(uint32 fromX, uint32 fromY, uint32 toX, uint32 toY) internal pure returns (uint32) {
    uint32 deltaX = fromX > toX ? fromX - toX : toX - fromX;
    uint32 deltaY = fromY > toY ? fromY - toY : toY - fromY;
    return deltaX + deltaY;
  }

  function spawn(uint32 x, uint32 y) public CheckObstruction(x,y){
    bytes32 player = addressToEntityKey(_msgSender());
    require(Player.get(player)==false,"already spawned");

    (uint32 width,uint32 height,) = MapConfig.get();
    require(x<width && y<height,"out map");

    Player.set(player,true);
    Position.set(player,x,y);
    Movable.set(player,true);
    Encounterable.set(player,true);
  }

  function move(uint32 x,uint32 y) public CheckObstruction(x,y){
    bytes32 player = addressToEntityKey(_msgSender());
    require(Movable.get(player),"can't move");

    (uint32 width,uint32 height,) = MapConfig.get();
    require(x<width && y<height,"out map");

    require(!Encounter.getExists(player),"during an encounter");

    (uint32 fromX) = Position.getX(player);
    uint32 fromY = Position.getY(player);
    require(distance(fromX, fromY, x, y)==1,"only more 1 step");

    Position.set(player,x,y);
    bytes32 position = positionToEntityKey(x,y);
    if(Encounterable.get(player) && EncounterTrigger.get(position)){
      uint256 rand = uint256(keccak256(abi.encode(player,position,blockhash(block.number-1),block.difficulty)));
      if(rand%5==0){
        startEncounter(player);
      }
    }
  }

  function startEncounter(bytes32 player) internal{
    //TODO
    bytes32 monster = keccak256(abi.encode(player,block.number,block.difficulty));
    uint256 randomType = (uint256(monster) % uint256(type(MonsterType).max))+1;
    MonsterType monsterType = MonsterType(randomType);
    Monster.set(monster,monsterType);
    Encounter.set(player,EncounterData({
      exists:true,
      monster:monster,
      catchAttempts:0
    }));
  }
}
