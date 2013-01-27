package ly.jamie.snake {
  import flash.display.MovieClip;
  import flash.events.*;
  import flash.ui.*;

  public class Program extends MovieClip {
    private var game: Game;
    private var framesPerStep:Number; 
    private var frameCount:Number; 
    private var enterFrameHandlerInitialized: Boolean = false;

    public function Program() {
      this.game = new Game(this, 20, 20);
      this.game.start();
      this.framesPerStep = 1; 
      this.frameCount = 0;
      trace("Created game: " + this.game)

      var self: Object = this;
      this.stage.addEventListener(KeyboardEvent.KEY_UP, 
        function(e:KeyboardEvent):void {
          self.ArrowListener.call(self, e);
        });
    }
    private function playGame():void {
      this.frameCount ++;
      if(this.frameCount % this.framesPerStep == 0) this.game.step();
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

              this.game.start();
              if(!enterFrameHandlerInitialized) {
                this.addEventListener(Event.ENTER_FRAME, playGame);
                enterFrameHandlerInitialized = true;
              }
              break;

          case Keyboard.HOME:
              this.game.barrierFrequency = ( this.game.barrierFrequency > 0 ) ? 0 : .05;
              break;
        }
      }
  }
}
