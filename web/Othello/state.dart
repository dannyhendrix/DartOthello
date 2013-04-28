part of othello;

/**
 * Othello
 * 
 * State class. This hadle the current state and calculates the next possible moves
 * 
 * @author Danny Hendrix
 */

class OthelloState
{
  static const int FIELD_EMPTY = 0;
  static const int FIELD_NONE = 1;
  static const int FIELD_WHITE = 2;
  static const int FIELD_BLACK = 3;
  
  static const int PLAYER_1 = 1;
  static const int PLAYER_2 = 2;
  
  static const int STATUS_RUNNING = 0;
  static const int STATUS_PLAYER1_WON = 1;
  static const int STATUS_PLAYER2_WON = 2;
  static const int STATUS_PLAYER1_WON_NO_MOVES = 3;
  static const int STATUS_PLAYER2_WON_NO_MOVES = 4;
  static const int STATUS_DRAW = 5;
  
  //scores
  int player1score = 0;
  int player2score = 0;
  
  int player1turns = 0;
  int player2turns = 0;
  
  //possible moves for the current player
  int options = 0;
  
  //skipped turns
  //skipping turns are measured in this instance only. When a move is done and a new instance of state is created, the skipped value is reset to 0.
  //if skipped == 2 then both player1 and player2 have no more options
  int skipped = 0;
  
  //whos turn
  int currentplayer = PLAYER_1;
  
  //current status of the game
  int status = STATUS_RUNNING;
  
  //gameboard
  Field _field;
  
  //possible moves and matching states
  Map<String,OthelloState> _options;
  
  OthelloState(int w, int h)
  {
    _field = new Field(w,h);
  }
  
  OthelloState.fromField(Field f)
  {
    _field = f;
  }
  
  //for creating a copy of a state
  OthelloState.fromState(OthelloState state)
  {
    currentplayer = state.currentplayer;
    player1turns = state.player1turns;
    player2turns = state.player2turns;
    player1score = state.player1score;
    player2score = state.player2score;
    _field = state._field.clone();
  }
  
  //when the state is picked, find the next possible states. And update the current status.
  void onSelect([bool nextplayer = true])
  {
    if(nextplayer == true)
    {
      _doTurn();
      _nextPlayer();
    }
    _setScore();
    status = _getStatus();
  }
  
  //set a value to a tile
  void setTile(int x, int y, int value)
  {
    //keep scores
    int old = _field.getTile(x,y);
    if(old == FIELD_BLACK)
      player2score--;
    if(old == FIELD_WHITE)
      player1score--;
    
    if(value == FIELD_BLACK)
      player2score++;
    if(value == FIELD_WHITE)
      player1score++;
    //set the value on the field
    _field.setTile(x, y, value);
  }
  
  int getValue(int x, int y)
  {
    if(x < 0 || x >= _field.w)
      return FIELD_NONE;
    if(y < 0 || y >= _field.h)
      return FIELD_NONE;
    return _field.getTile(x, y);
  }
  
  void skipturn()
  {
    skipped++;
    if(skipped == 2)
    {
      if(player1score == player2score)
        status = STATUS_DRAW;
      if(player1score > player2score)
        status = STATUS_PLAYER1_WON;
      if(player1score < player2score)
        status = STATUS_PLAYER2_WON;
    }
    _nextPlayer();
    _setScore();
  }
  
  void _doTurn()
  {
    if(currentplayer == PLAYER_1)
      player1turns++;
    else
      player2turns++;
  }
  
  //creates a list with directions. First value == ([1] || [2] || .. || [n])
  //the next values indicate the direction
  List<bool> _getAllowedList(int x, int y, int value, int valueR)
  {
    int fval = getValue(x,y);
    if(fval != FIELD_EMPTY)
    {
      return new List<bool>.filled(9,false);
    }
    bool allowed = false;
    List<bool> allowedrow = new List<bool>.filled(9,false);
    //skip first
    int i = 1;
    //check all directions if flipping is allowed
    for(int addx = -1; addx <= 1; addx++)
      for(int addy = -1; addy <= 1; addy++)
      {
        if(addx == 0 && addy == 0)
          continue;
        if(_isAllowed(x,y,valueR,value,addx,addy))
        {
          allowed = true;
          allowedrow[i] = true;
        }
        i++;
      }
    allowedrow[0] = allowed;
    return allowedrow;
  }
  
  //"flip" the tiles based on the allowed directions
  void _placeTileFromAllowedList(List<bool> allowedrow, int x, int y, int value, int valueR)
  {
    if(allowedrow[0] == false)
      return;
    //skip first in allowed list
    int i = 1;
    //flip tiles untill you find the other players tile
    for(int addx = -1; addx <= 1; addx++)
      for(int addy = -1; addy <= 1; addy++)
      {
        if(addx == 0 && addy == 0)
          continue;
        if(allowedrow[i++] == false)
          continue;
        _flipRow(x,y,valueR,value,addx,addy);
      }
    //flip actual tile itself
    setTile(x,y,value);
  }
  
  //reversed value returns the otherplayers tile
  int _reversedField(int fieldvalue)
  {
    if(fieldvalue == FIELD_WHITE)
      return FIELD_BLACK;
    if(fieldvalue == FIELD_BLACK)
      return FIELD_WHITE;
    return fieldvalue;
  }
  
  //check if a direction is allowed. The xadd and yadd define the direction. Forinstance left to right horizontal: xadd = 1, yadd = 0
  bool _isAllowed(int xstart, int ystart, int newvalR, int newval, int xadd, int yadd)
  {
    int val;
    //search while there are oposite tiles untill a tile from the player is reacher or an empty tile or the border
    for(int x = xstart+xadd, y = ystart+yadd, depth = 0; x>=0 && x < _field.w && y >= 0 && y < _field.h; x+=xadd,y+=yadd, depth++)
    {
      val = getValue(x,y);
      //the first tile next to the tile cannot be the final tile
      if(val == newval)
        return depth > 0;
      //empty tile or blocked tile
      if(val != newvalR)
        return false;
    }
    //border reached
    return false;
  }
  
  //flip the tiles found with the _isAllowed method
  //should only be called when _isAllowed with the same parameters returns true.
  void _flipRow(int xstart, int ystart, int newvalR, int newval, int xadd, int yadd)
  {
    int val;
    //this might aswell be a whileloop, be just te be save .. :)
    //flip tiles untill it finds a tile with the same value
    for(int x = xstart+xadd, y = ystart+yadd; x>=0 && x < _field.w && y >= 0 && y < _field.h; x+=xadd,y+=yadd)
    {
      val = getValue(x,y);
      if(val == newval)
        return;
      if(val == newvalR)
        setTile(x,y,newval);
    }
  }
  
  //turn is over, change player
  void _nextPlayer()
  {
    if(currentplayer == PLAYER_1)
      currentplayer = PLAYER_2;
    else if(currentplayer == PLAYER_2)
      currentplayer = PLAYER_1;
  }
  
  //calculate the next possible moves
  void _setScore()
  {
    int val;
    String index;

    _options = new Map<String,OthelloState>();
    options = 0;
    
    for(int x = 0; x < _field.w; x++)
      for(int y = 0; y < _field.h; y++)
      {
        val = getValue(x,y);

        //border or non placable tile
        if(val == FIELD_NONE)
          continue;
          
        int value = (currentplayer == PLAYER_1) ? FIELD_WHITE : FIELD_BLACK;
        //reversed value
        int valueR = _reversedField(value);
        
        //check if the tile can be played
        List<bool> allowedlist = _getAllowedList(x,y,value,valueR);
        if(allowedlist[0] == true)
        {
          index = "$x-$y";
          //create a new state for the possible move
          OthelloState newstate = new OthelloState.fromState(this);
          newstate._placeTileFromAllowedList(allowedlist,x,y,value,valueR);
          _options[index] = newstate;
          
          options++;
        }
      }
  }
  
  //find the currentstatus of the game
  int _getStatus()
  {
    //no more possible moves because the player has no tiles on the field
    if(player1score == 0)
      return STATUS_PLAYER2_WON_NO_MOVES;
    if(player2score == 0)
      return STATUS_PLAYER1_WON_NO_MOVES;
    
    int tot = player1score + player2score;
    //all tiles are placed
    if(tot == _field.totalfields)
    {
      if(player1score == player2score)
        return STATUS_DRAW;
      if(player1score > player2score)
        return STATUS_PLAYER1_WON;
      if(player1score < player2score)
        return STATUS_PLAYER2_WON;
    }
    //game not finished
    return STATUS_RUNNING;
  }
  
  Map<String,OthelloState> getNextOptions()
  {
    return _options;
  }
  
  Field getField()
  {
    return _field;
  }
}

