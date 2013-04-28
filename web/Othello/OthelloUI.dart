part of othello;

/**
 * Othello
 * 
 * This class handles the UI of the game. This is a simple implementation using the canvas.
 * 
 * 
 * @author Danny Hendrix
 */
class OthelloUI
{
  Othello game;
  String key;
  OthelloUICanvas maincanvas;
  
  DivElement el_menu;
  DivElement el_game;
  
  bool ended = false;
  
  OthelloUI(this.game)
  {
    el_menu = document.query("#menuframe");
    el_game = document.query("#gameframe");
    
    //add levels to UI
    setLevels();
    ButtonElement button = document.query("#quit");
    button.onClick.listen((MouseEvent e){
      document.query("#message").nodes.clear();
      el_game.style.display = "none";
      el_menu.style.display = "block";
      ended = false;
    });
  }
  
  void setLevels()
  {
    DivElement el = document.query("#levels");
    game.levels.forEach(
        (String key, Field f){
          CanvasElement cv = new Element.tag("canvas");
          OthelloUICanvasLevel prev = new OthelloUICanvasLevel(this,cv,key);
          prev.drawField(f);
          el.nodes.add(cv);
        }    
    );
  }
  
  void init(OthelloState initialstate)
  {
    maincanvas = new OthelloUICanvas(this, document.query("#game"));
    maincanvas.init(initialstate);
    setState(initialstate);
    
    el_menu.style.display = "none";
    el_game.style.display = "block";
  }

  void setState(OthelloState state)
  {
    //clear message
    DivElement el = document.query("#message");
    el.nodes.clear();
    
    //update the othello game canvas
    maincanvas.update(state);
    
    if(state.skipped == 1)
    {
      String player = "Player1";
      if(state.currentplayer == OthelloState.PLAYER_1)
        if(game.player2iscpu)
          player = "CPU";
        else
          player = "Player2";
      el.nodes.add(new Element.html("<p>$player skipped a turn!</p>"));
    }
    
    //update options
    _setPreview(state);
    
    //status
    String html = "";
    String p1html = "Player1 turns: ${state.player1turns} score: ${state.player1score}";
    if(state.currentplayer == OthelloState.PLAYER_1)
      html += "<b>$p1html</b>";
    else
      html += p1html;
    
    html += "<br/>";
    
    String player2 = (game.player2iscpu) ? "CPU" : "Player2";
    String p2html = "$player2 turns: ${state.player2turns} score: ${state.player2score}";
    if(state.currentplayer == OthelloState.PLAYER_2)
      html += "<b>$p2html</b>";
    else
      html += p2html;
    
    html += "<br/> Possible moves: ${state.options}";
   
    document.query("#status").innerHtml = html;
  }
  
  void _setPreview(OthelloState state)
  {
    DivElement el = document.query("#preview");
    //remove all previous previews
    el.nodes.clear();
    
    //when there are 0 options, display a skip turn button
    if(state.getNextOptions().length == 0)
    {
      el = document.query("#message");
      el.nodes.add(new Element.html("<p>No possible moves!</p>"));
      ButtonElement btn = new Element.tag("button");
      btn.text = "Skip turn";
      btn.onClick.listen((Event e){
        game.doOption("skip");
      });
      el.nodes.add(btn);
      return;
    }
    
    //append options
    state.getNextOptions().forEach(
      (String key, OthelloState s){
        CanvasElement cv = new Element.tag("canvas");
        OthelloUICanvasPreview prev = new OthelloUICanvasPreview(this,cv,key);
        prev.init(s);
        el.nodes.add(cv);
      }    
    );
    
  }
  
  void startLevel(String level)
  {
    SelectElement s = document.query("#opponent");
    if(s.value == "1")
      game.setOpponentIsCPU(false);
    game.startLevel(level);
  }
  
  void setEndState(OthelloState state)
  {
    if(ended == true)
      return;
    setState(state);
    DivElement el = document.query("#message");
    el.nodes.clear();
    String msg;
    String player2 = (game.player2iscpu) ? "CPU" : "Player2";

    switch(state.status)
    {
      case OthelloState.STATUS_DRAW:
        msg = "Game over .. draw!";
        break;
      case OthelloState.STATUS_PLAYER1_WON:
        msg = "Game over. Player1 won!";
        break;
      case OthelloState.STATUS_PLAYER2_WON:
        msg = "Game over. $player2 won!";
        break;
      case OthelloState.STATUS_PLAYER1_WON_NO_MOVES:
        msg = "Game over, no possible moves. Player1 won!";
        break;
      case OthelloState.STATUS_PLAYER2_WON_NO_MOVES:
        msg = "Game over, no possible moves. $player2 won!";
        break;
    }
    el.nodes.add(new Element.html("<p>$msg</p>"));
    ButtonElement button = new Element.tag("button");
    button.text = "Play again";
    button.onClick.listen((MouseEvent e){
      el.nodes.clear();
      el_game.style.display = "none";
      el_menu.style.display = "block";
      ended = false;
    });
    el.nodes.add(button);
    ended = true;
  }
}

