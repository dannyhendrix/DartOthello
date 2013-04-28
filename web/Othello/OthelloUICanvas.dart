part of othello;
/**
 * Othello
 * 
 * Display a state using the canvas
 * 
 * 
 * @author Danny Hendrix
 */
class OthelloUICanvas
{
  int _tilew = 32;
  int _tileh = 32;
  
  int _fieldTilesW = 0;
  int _fieldTilesH = 0;
  
  int _paddingx = 5;
  int _paddingy = 5;
  
  CanvasElement _whitePiece;
  CanvasElement _blackPiece;
  
  CanvasElement element;
  CanvasRenderingContext2D _gamectx;
  
  OthelloUI mainui;
  
  OthelloUICanvas(this.mainui, this.element);
  
  void init(OthelloState initialstate)
  {
    _fieldTilesH = initialstate._field.h;
    _fieldTilesW = initialstate._field.w;
    
    _whitePiece = _createPiece(true);
    _blackPiece = _createPiece(false);

    element.width = (_fieldTilesW * (_tilew + _paddingx)) + _paddingx;
    element.height = (_fieldTilesH * (_tileh + _paddingy)) + _paddingy;
    _gamectx = element.getContext("2d");
    _gamectx.fillStyle = "rgb(210,210,210)";
    
    element.onClick.listen(_onMouseClick);
  }
  
  CanvasElement _createPiece(bool white)
  {
    //create a drawable piece for the player
    CanvasElement cv = new Element.tag("canvas");
    cv.height = _tileh;
    cv.width = _tilew;
    CanvasRenderingContext2D ctx = cv.getContext("2d");
    if(white)
      ctx.fillStyle = "rgb(255,102,0)";
    else
      ctx.fillStyle = "rgb(40,40,40)";
    //draw circle
    ctx.beginPath();
    ctx.arc(_tilew/2, _tileh/2, _tilew/2, 0, Math.PI*2, true); 
    ctx.closePath();
    ctx.fill();
    return cv;
  }
  
  void update(OthelloState state)
  {
    _draw(state.getField());
  }
  
  void _draw(Field f)
  {
    int fieldval;
    _gamectx.clearRect(0, 0, element.width, element.height);
    //draw all tiles
    for(int x = 0, dx = _paddingx; x < f.w; x++, dx += _tilew + _paddingx)
      for(int y = 0, dy = _paddingy; y < f.h; y++, dy += _tileh + _paddingy)
      {
        fieldval = f.getTile(x,y);
        if(fieldval == OthelloState.FIELD_WHITE)
          _gamectx.drawImage(_whitePiece, dx, dy);
        else if(fieldval == OthelloState.FIELD_BLACK)
          _gamectx.drawImage(_blackPiece, dx, dy);
        else if(fieldval != OthelloState.FIELD_NONE)
          _gamectx.fillRect(dx, dy, _tilew, _tileh);
      }
  }
  
  void _onMouseClick(MouseEvent e)
  {
    //find the x and y the player has clicked on
    int x =  Math.min(_fieldTilesW,(e.offset.x - (_paddingx ~/ 2)) ~/ (_tilew + _paddingx));
    int y = Math.min(_fieldTilesH,(e.offset.y - (_paddingy ~/ 2)) ~/ (_tileh + _paddingy));
    mainui.game.placeTile(x,y);
  }
}

//element for showing posible moves
class OthelloUICanvasPreview extends OthelloUICanvas
{
  //key for the move
  String key;
  
  OthelloUICanvasPreview(OthelloUI mainui, CanvasElement e, this.key): super(mainui,e)
  {
    _tilew = 8;
    _tileh = 8;
    _paddingx = 2;
    _paddingy = 2;
  }
  
  void _onMouseClick(MouseEvent e)
  {
    mainui.game.doOption(key);
  }
  
  void init(OthelloState state)
  {
    super.init(state);
    _draw(state.getField());
  }
}

class OthelloUICanvasLevel extends OthelloUICanvas
{
  //key for the move
  String key;
  
  OthelloUICanvasLevel(OthelloUI mainui, CanvasElement e, this.key): super(mainui,e)
  {
    _tilew = 8;
    _tileh = 8;
    _paddingx = 2;
    _paddingy = 2;
  }
  
  void _onMouseClick(MouseEvent e)
  {
    mainui.startLevel(key);
  }
  
  void drawField(Field f)
  {
    _fieldTilesH = f.h;
    _fieldTilesW = f.w;

    element.width = (_fieldTilesW * (_tilew + _paddingx)) + _paddingx;
    element.height = (_fieldTilesH * (_tileh + _paddingy)) + _paddingy;
    _gamectx = element.getContext("2d");
    _gamectx.fillStyle = "rgb(210,210,210)";
    
    element.onClick.listen(_onMouseClick);
    
    _draw(f);
  }
}

