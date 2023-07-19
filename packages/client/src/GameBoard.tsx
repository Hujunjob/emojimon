import { Entity, Has, getComponentValue, getComponentValueStrict } from "@latticexyz/recs";
import { GameMap } from "./GameMap";
import { useMUD } from "./MUDContext";
import { useKeyboardMovement } from "./useKeyboardMovement";
import { useComponentValue, useEntityQuery } from "@latticexyz/react";
import { TerrainType, terrainTypes } from "./terrainTypes";
import { hexToArray } from "@latticexyz/utils";
import { MonsterType, monsterTypes } from "./monsterTypes";
import { EncounterScreen } from "./EncounterScreen";

export const GameBoard = () => {
  const { systemCalls, network, components } = useMUD()

  useKeyboardMovement()
  var canSpawn = useComponentValue(components.Player, network.playerEntity)?.value != true

  // var playerExist = useComponentValue(components.Player, network.playerEntity)
  // var position = useComponentValue(components.Position, network.playerEntity)

  // const player = playerExist && position ? {
  //   x: position.x,
  //   y: position.y,
  //   emoji: "🤖",
  //   entity: network.playerEntity!
  // } : null

  const players = useEntityQuery([Has(components.Player),Has(components.Position)]).map(entity=>{
      var posision = getComponentValueStrict(components.Position,entity)
      return{
        entity,
        x:posision.x,
        y:posision.y,
        emoji:entity==network.playerEntity?"🤠":"🧌"
      }
  })


  console.log("canspawan %s", canSpawn)

  const mapConfig = useComponentValue(components.MapConfig, network.singletonEntity);
  if (mapConfig == null) {
    return
  }

  const { width, height, terrian } = mapConfig;
  const terrians = Array.from(hexToArray(terrian)).map((value, index) => {
    const emoji = value in TerrainType ? terrainTypes[value as TerrainType].emoji : ""
    return {
      x: index % width,
      y: Math.floor(index / width),
      emoji: emoji
    }
  })

  const encounter = useComponentValue(components.Encounter, network.playerEntity)
  const monsterType = useComponentValue(components.Monster, encounter ? (encounter.monster as Entity) : undefined)?.value
  const monster = monsterType != null && monsterType in MonsterType ? monsterTypes[monsterType as MonsterType] : null

  const encounterNode = encounter ? <EncounterScreen monsterName={monster?.name!!} monsterEmoji={monster?.emoji!!} /> : undefined

  return <GameMap width={20} height={20} encounter={encounterNode} terrain={terrians} players={players} onTileClick={
    canSpawn ? systemCalls.spawn : undefined
  } />;
};
