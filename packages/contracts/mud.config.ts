import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  systems:{

  },
  enums: {
    // TODO
    TerrianType:["None","TallGrass","Boulder"],
    MonsterType:["None","Eagle","Rat","Caterpillar"],
    MonsterCatchResult:["Missed","Caught","Fled"],
  },
  tables: {
    MonsterCatchAttempt:{
      ephemeral:true,
      dataStruct:false,
      keySchema:{
        encounter:"bytes32"
      },
      schema:{
        result:"MonsterCatchResult"
      }
    },
    OwnedBy:"bytes32",
    MapConfig:{
      keySchema:{},
      dataStruct:false,
      schema:{
        width:"uint32",
        height:"uint32",
        terrian:"bytes",
      }
    },
    Monster:"MonsterType",
    Obstruction:"bool",
    Player:"bool",
    Movable:"bool",
    Position:{
      dataStruct:true,
      schema:{
        x:"uint32",
        y:"uint32"
      }
    },
    EncounterTrigger:"bool",   //is the position is encounter trigger
    Encounterable:"bool",   //is the entity encounterable
    Encounter:{
      keySchema:{
        player:"bytes32"
      },
      schema:{
        exists:"bool",
        monster:"bytes32",
        catchAttempts:"uint256",
      }
    }
  },
});
