package ly.jamie.snake {
  import flash.display.MovieClip;
  import flash.events.*;
  import flash.ui.*;
  import flash.text.*;

  public class Program extends MovieClip {
    private var game: Game;
    private var framesPerStep:Number; 
    private var frameCount:Number; 
    private var enterFrameHandlerInitialized: Boolean = false;
    private var txtDebug:TextField;
    private var barriesOn:Boolean = true;

    public function Program() {
      debug("init program");
      this.framesPerStep = 3; 
      this.frameCount = 0;

      var self: Object = this;
      this.stage.addEventListener(KeyboardEvent.KEY_UP, 
        function(e:KeyboardEvent):void {
          self.ArrowListener.call(self, e);
        });
      this.start();
      this.handleEnterFrame();
      this.createInstructions();
    }
    private function createInstructions(): void {
      var tf: TextField = new TextField();
      tf.defaultTextFormat = new TextFormat("Verdana", 12);
      tf.htmlText = "<b>Instructions</b>\n<ul>Objectives\n<li>Avoid brown obstacles</li>\n<li>Eat red pellets</li></ul>\n<ul>Controls\n<li>L,R,U,D to move the Snake</li>\n<li>Space to restart</li>\n<li>CTRL to toggle obstacles</li></ul>";
      tf.x = 230;
      tf.width = 200;
      tf.height = 200;
      this.addChild(tf);
    }
    private function createGame(): void {
      var self: Object = this;
      if(this.game) {
        //cleanup
        this.removeChild(this.game);
        this.game = null;
      }
      this.game = new Game(20, 20);
      this.game.debug = function(msg:String):void {
        self.debug.call(self, msg);
      };
      this.addChild(this.game);
    }
    private function start():void {
      try { 
        this.createGame();
        this.game.barrierFrequency = this.barriesOn ? 0.05 : 0;
        this.game.start(); 
      }
      catch(ex:*) { debug("Problem starting: " + ex.message); }
    }
    private function debug(msg:String): void {
      if(! this.txtDebug) {
        txtDebug = new TextField();
        txtDebug.x = 230;
        txtDebug.y = 120;
        txtDebug.width = 300;
        txtDebug.height = 100;
        txtDebug.alpha = .5;
        txtDebug.defaultTextFormat = new TextFormat("Verdana", 8);
        this.addChild(txtDebug);
      }
      txtDebug.text = msg + "\n" + txtDebug.text;
    }
    private function playGame():void {
      try {
        this.frameCount ++;
        if(this.frameCount % this.framesPerStep == 0 && ! this.game.isGameOver) {
          this.game.step();
        }
      }
      catch(ex:*) {
        debug("Problem stepping game: " + ex.message);
      }
    }

    private function handleEnterFrame():void {
        if(!enterFrameHandlerInitialized) {
          var self:Object = this;
          this.addEventListener(Event.ENTER_FRAME, function():void{
            self.playGame();
          });
          enterFrameHandlerInitialized = true;
        }
    }

    private function ArrowListener(e:KeyboardEvent):void {
      switch(e.keyCode) {
          case Keyboard.UP:
              if(this.game.getDirection() == 2) break;
              this.game.setDirection(0);
              break;
          case Keyboard.RIGHT:
              if(this.game.getDirection() == 3) break;
              this.game.setDirection(1);
              break;
          case Keyboard.DOWN:
              if(this.game.getDirection() == 0) break;
              this.game.setDirection(2);
              break;
          case Keyboard.LEFT:
              if(this.game.getDirection() == 1) break;
              this.game.setDirection(3);
              break;
          case Keyboard.SPACE:

              this.start();
              this.handleEnterFrame();
              break;

          case Keyboard.CONTROL:
          case Keyboard.DELETE:
          case Keyboard.HOME:
              this.barriesOn = ! this.barriesOn;
              debug("Toggled barriers to " + 
                (this.barriesOn ? "off" : "on"));
              this.start();
              this.handleEnterFrame();
              break;
        }
      }
  }
}

