import { Has, HasValue, getComponentValue, runQuery } from "@latticexyz/recs";
import { uuid, awaitStreamValue } from "@latticexyz/utils";
import { MonsterCatchResult } from "../monsterCatchResult";
import { ClientComponents } from "./createClientComponents";
import { SetupNetworkResult } from "./setupNetwork";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  { singletonEntity, playerEntity, worldSend, txReduced$ }: SetupNetworkResult,
  {Position,Player,Encounter,MonsterCatchAttempt, MapConfig, Obstruction}: ClientComponents
) {

  const isInMap =  (x:number,y:number)=>{
    const mapConfig =  getComponentValue(MapConfig,singletonEntity)
    if(!mapConfig){
      return false;
    }
    var width = mapConfig.width;
    var height = mapConfig.height;
    if(x<0 || y<0 || x>=width || y>=height){
      return false;
    }
    return true;
  }

  const wrapPosition =  (x:number,y:number)=>{
    const mapConfig =  getComponentValue(MapConfig,singletonEntity)
    if(!mapConfig){
      return [x,y];
    }
    var width = mapConfig.width;
    var height = mapConfig.height;
    // return [(x+width)%width,(y+height)%height ];
    return [x,y];
  }

    const isObstruction = (x:number,y:number)=>{
      return runQuery([Has(Obstruction),HasValue(Position,{x,y})]).size>0;
    }

  const moveTo = async (inputX: number, inputY: number) => {
    if(!playerEntity){
      return
    }
    
    const [x,y]=wrapPosition(inputX,inputY);
    if(!isInMap(x,y)){
      console.log("out of map");
      return;
    }
    if(getComponentValue(Encounter,playerEntity)){
      console.log("is in encounter");
      return
    }
    
    // const mapConfig =  getComponentValue(MapConfig,singletonEntity)
    // if(!mapConfig){
    //   // return [x,y];
    //   return
    // }
    console.log("inputx:%s,input y:%s,x:%s,y:%s",inputX,inputY,x,y)
    if(isObstruction(x,y)){
      console.log("is stone");
      return
    }

    const positionId = uuid();
    Position.addOverride(positionId,{
      entity:playerEntity,
      value:{x,y}
    })

    // TODO
    try{
      var tx =  await worldSend("move",[x,y]);
      await awaitStreamValue(txReduced$,(txHash)=>txHash === tx.hash)
    }finally{
      Position.removeOverride(positionId);
    }
  };

  const moveBy = async (deltaX: number, deltaY: number) => {
    if(!playerEntity){
      return
    }
    var position =  getComponentValue(Position,playerEntity)
    if(!position){
      return
    }
    await moveTo(position?.x+deltaX,position?.y+deltaY)
    // TODO
    // return null as any;
  };

  const spawn = async (inputX: number, inputY: number) => {
    if(!playerEntity){
      return
    }
    const [x,y]=wrapPosition(inputX,inputY);
    if(!isInMap(x,y)){
      console.log("out of map");
      return;
    }
    if(isObstruction(x,y)){
      console.log("is stone");
      return
    }
    const player = getComponentValue(Player,playerEntity)
    if(player){
      if(player.value){
        console.log("already exist")
        return
      }
    }
    // TODO
    const tx = await worldSend("spawn",[x,y])
    await awaitStreamValue(txReduced$,(txHash)=>txHash===tx.hash)
    // return null as any;
  };

  const throwBall = async () => {
    if(!playerEntity){
      return
    }

    // const player = getComponentValue(Player,playerEntity)
    const encounter= getComponentValue(Encounter,playerEntity);
    if(!encounter){
      console.log("Not encounter");
      return;
    }

    const tx = await worldSend("throwBall",[]);
    await awaitStreamValue(txReduced$,(txHash)=>txHash===tx.hash);

    const attempt =  getComponentValue(MonsterCatchAttempt,playerEntity)
    if(!attempt){
      console.log("catch error");
      return
    }

    return attempt.result as MonsterCatchResult
  };

  const fleeEncounter = async () => {
    if(!playerEntity){
      return
    }

    // const player = getComponentValue(Player,playerEntity)
    const encounter= getComponentValue(Encounter,playerEntity);
    if(!encounter){
      console.log("Not encounter");
      return;
    }

    const tx = await worldSend("flee",[]);
    await awaitStreamValue(txReduced$,(txHash)=>txHash===tx.hash)
  };

  return {
    moveTo,
    moveBy,
    spawn,
    throwBall,
    fleeEncounter,
  };
}
