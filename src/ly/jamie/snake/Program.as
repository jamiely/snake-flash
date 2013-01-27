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

    public function Program() {
      debug("init program");
      this.framesPerStep = 1; 
      this.frameCount = 0;
      trace("Created game: " + this.game)

      var self: Object = this;
      this.game = new Game(this, 20, 20);
      this.game.debug = function(msg:String):void {
        self.debug.call(self, msg);
      };
      this.stage.addEventListener(KeyboardEvent.KEY_UP, 
        function(e:KeyboardEvent):void {
          self.ArrowListener.call(self, e);
        });
      with(this.graphics) {
        beginFill(0x3333FF);
        drawRect(0, 0, 800, 1000);
        endFill();
      }
      debug("End init program")
      this.start();
      this.handleEnterFrame();
      debug("Started game");
    }
    private function start():void {
      try { this.game.start(); }
      catch(ex:*) { debug("Problem starting: " + ex.message); }
    }
    private function debug(msg:String): void {
      if(! this.txtDebug) {
        txtDebug = new TextField();
        txtDebug.x = 200;
        txtDebug.y = 100;
        txtDebug.width = 300;
        txtDebug.alpha = .5;
        txtDebug.defaultTextFormat = new TextFormat("Verdana", 14);
        this.addChild(txtDebug);
      }
      txtDebug.text = msg + "\n" + txtDebug.text;
    }
    private function playGame():void {
      try {
        this.frameCount ++;
        if(this.frameCount % this.framesPerStep == 0) {
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
      debug("Key event: " + e.keyCode);
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

          case Keyboard.HOME:
              this.game.barrierFrequency = ( this.game.barrierFrequency > 0 ) ? 0 : .05;
              break;
        }
      }
  }
}

