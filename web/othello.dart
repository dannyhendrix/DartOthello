/**
 * Othello
 * 
 * 
 * @author Danny Hendrix
 */
library othello;

import 'dart:html';
import 'dart:math' as Math;

part "Othello/state.dart";
part "Othello/field.dart";
part "Othello/cpu.dart";
part "Othello/OthelloUI.dart";
part "Othello/OthelloUICanvas.dart";

void main() 
{
  new Othello();
}

class Othello
{
  OthelloState currentstate;
  OthelloUI ui;
  CPU cpu;
  
  bool player2iscpu = true;
  
  Map<String,Field> levels;
  
  Othello()
  {
    setLevels();
    
    //initialize the UI
    ui = new OthelloUI(this);
  }
  
  setOpponentIsCPU(bool val)
  {
    player2iscpu = val;
  }
  
  void setLevels()
  {
    levels = new Map<String,Field>();
    levels["1Small"] = new Field(6, 6);
    levels["2Normal"] = new Field(8, 8);
    levels["3Large"] = new Field(16, 16);
    levels["4Odd"] = new Field(20, 10);
    levels["5Shape"] = new Field.fromArray([[1,0,0,0,0,0,0,1],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,1],[1,0,0,0,0,0,0,1],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[1,0,0,0,0,0,0,1]]);
  }
  
  void startLevel(String key)
  {
    Field f = levels[key].clone();
    int fw = f.w;
    int fh = f.h;

    currentstate = new OthelloState.fromField(f);
    
    //place start tiles in the center
    currentstate.setTile((fw~/2)-1, (fh~/2)-1, OthelloState.FIELD_WHITE);
    currentstate.setTile(fw~/2, fh~/2, OthelloState.FIELD_WHITE);
    
    currentstate.setTile(fw~/2, (fh~/2)-1, OthelloState.FIELD_BLACK);
    currentstate.setTile((fw~/2)-1, fh~/2, OthelloState.FIELD_BLACK);
    
    //start the first turn and set the next possible moves
    currentstate.onSelect(false);
    
    ui.init(currentstate);
    
    //cpu
    if(player2iscpu)
      cpu = new CPU();
  }
  
  //Place a tile (or atleast try to :P)
  void placeTile(int x, int y)
  {
    String index = "$x-$y";
    doOption(index);
  }
  
  //move to the state with the given key
  void doOption(String index)
  {
    if(currentstate.status != OthelloState.STATUS_RUNNING)
    {
      ui.setEndState(currentstate);
      return;
    }
    
    if(index != "skip" && currentstate.getNextOptions().containsKey(index) == false)
      return;
    
    //skip a turn when no possible moves
    if(index == "skip")
    {
      currentstate.skipturn();
    }
    else
    {
      //move to the given state
      currentstate = currentstate.getNextOptions()[index];
      //find next possible states and go to next player etc..
      currentstate.onSelect();
    }
    
    if(currentstate.status != OthelloState.STATUS_RUNNING)
    {
      ui.setEndState(currentstate);
      return;
    }
    //CPU turn
    if(player2iscpu == true && currentstate.currentplayer == OthelloState.PLAYER_2)
    {
      String k = cpu.nextMove(currentstate);
      return doOption(k);
    }
    else
    {
      //if it was the CPUs turn, show the current gamestate
      if(currentstate.status != OthelloState.STATUS_RUNNING)
        ui.setEndState(currentstate);
      else
        ui.setState(currentstate);
    }
  }
}
