part of othello;

/**
 * Othello
 * 
 * Simple AI. The CPU can think 1 turn ahead. This can be extended but atm 1 turn ahead seems hard enough ;)
 * 
 * 
 * @author Danny Hendrix
 */

class CPU
{
  //get the CPU's next move
  String nextMove(OthelloState state)
  {
    if(state.getNextOptions().length == 0)
      return "skip";
    int score = 0;
    String res;
    
    OthelloState s;
    for(String key in state.getNextOptions().keys)
    {
      s = state.getNextOptions()[key];
      if(score < s.player2score)
      {
        res = key;
        score = s.player2score;
      }
    }
    return res;
  }
}

