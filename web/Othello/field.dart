part of othello;

/**
 * Othello
 * 
 * gameboard/field of the game
 * 
 * 
 * @author Danny Hendrix
 */

class Field
{
  //gameboard grid [y][x]
  List<List<int>> _field;
  int w;
  int h;
  int totalfields = 0;
  
  //create default field
  Field(this.w, this.h)
  {
    _field = new List(h);
    for(int i = 0; i < h; i++)
      _field[i] = new List.filled(w, OthelloState.FIELD_EMPTY);
    totalfields = w*h;
  }
  
  //create an existing field
  //f should be of type [int][int] => int
  Field.fromArray(List f)
  {
    h = f.length;
    w = f[0].length;
    _field = f;
    
    //set the totalfields
    for(int i = 0; i < h; i++)
      for(int j = 0; j < w; j++)
        if(_field[i][j] == OthelloState.FIELD_EMPTY)
          totalfields++;
  }
  
  //the state class requires the field to be copied
  Field.fromField(Field f)
  {
    w = f.w;
    h = f.h;
    totalfields = f.totalfields;
    
    _field = new List(h);
    //all values have to be individually copied.
    for(int i = 0; i < h; i++)
    {
      _field[i] = new List(w);
      for(int j = 0; j < w; j++)
        _field[i][j] = f._field[i][j];
    }
  }
  //setter to hide the actual implementation of the field
  void setTile(int x, int y, int value)
  {
    _field[y][x] = value;
  }
  //getter to hide the actual implementation of the field
  int getTile(int x, int y)
  {
    return _field[y][x];
  }
  
  Field clone()
  {
    return new Field.fromField(this);
  }
}