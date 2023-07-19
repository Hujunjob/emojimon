// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import {MapConfig,Position,Obstruction,EncounterTrigger} from "../src/codegen/Tables.sol";
import {TerrianType} from "../src/codegen/Types.sol";
import {positionToEntityKey} from "../src/positionToEntityKey.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    IWorld world = IWorld(worldAddress);

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);
  // None,
  // TallGrass,
  // Boulder
    // Create a map
    TerrianType O = TerrianType.None;
    TerrianType T = TerrianType.TallGrass;
    TerrianType B = TerrianType.Boulder;

    TerrianType[20][20] memory map = [
      [O,O,O,O,O,O,T,O,T,B,O,O,T,O,O,B,O,O,T,O],
      [O,O,O,O,O,O,T,O,T,B,O,O,T,O,O,B,O,O,T,O],
      [O,O,O,O,O,O,T,O,T,B,O,O,T,O,O,B,O,O,T,O],
      [O,O,O,O,O,O,T,O,T,B,O,O,T,O,O,B,O,O,T,O],
            [O,O,O,O,O,O,T,O,T,B,O,O,T,O,O,B,O,O,T,O],
      [O,O,O,O,O,O,T,O,T,B,O,O,T,O,O,B,O,O,T,O],
      [O,O,O,O,O,O,T,O,T,B,O,O,T,O,O,B,O,O,T,O],
      [O,O,O,O,O,O,T,O,T,B,O,O,T,O,O,B,O,O,T,O],
            [O,O,O,O,O,O,T,O,T,B,O,O,T,O,O,B,O,O,T,O],
      [O,O,O,O,O,O,T,O,T,B,O,O,T,O,O,B,O,O,T,O],
      [O,O,O,O,O,O,T,O,T,B,O,O,T,O,O,B,O,O,T,O],
      [O,O,O,O,O,O,T,O,T,B,O,O,T,O,O,B,O,O,T,O],
            [O,O,O,O,O,O,T,O,T,B,O,O,T,O,O,B,O,O,T,O],
      [O,O,O,O,O,O,T,O,T,B,O,O,T,O,O,B,O,O,T,O],
      [O,O,O,O,O,O,T,O,T,B,O,O,T,O,O,B,O,O,T,O],
      [O,O,O,O,O,O,T,O,T,B,O,O,T,O,O,B,O,O,T,O],
            [O,O,O,O,O,O,T,O,T,B,O,O,T,O,O,B,O,O,T,O],
      [O,O,O,O,O,O,T,O,T,B,O,O,T,O,O,B,O,O,T,O],
      [O,O,O,O,O,O,T,O,T,B,O,O,T,O,O,B,O,O,T,O],
      [O,O,O,O,O,O,T,O,T,B,O,O,T,O,O,B,O,O,T,O]
    ];

    uint32 width = uint32(map.length);
    uint32 height = uint32(map[0].length);
    bytes memory terrian = new bytes(width*height);

  for (uint32 y = 0; y < height; y++) {
      for (uint32 x = 0; x < width; x++) {
        TerrianType terrianType = map[y][x];
        if(terrianType==TerrianType.None){
          continue;
        }
        terrian[y*width + x] = bytes1(uint8(terrianType));

        bytes32 entity = positionToEntityKey(x,y);
        Position.set(world,entity,x,y);
        if(terrianType==TerrianType.Boulder){
          Obstruction.set(world,entity,true);
        }else{
          EncounterTrigger.set(world,entity,true);
        }
      }
  }

    MapConfig.set(world,width,height,terrian);

    vm.stopBroadcast();
  }
}
