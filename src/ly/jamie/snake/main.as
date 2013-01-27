// snake.as

#include "Game.as"


this.game = new Game(_root, 20, 20);
this.game.start();
this.framesPerStep = 1; 
this.frameCount = 0;
trace("Created game: " + this.game)

this.playGame = function() {
    this.frameCount ++;
    if(this.frameCount % this.framesPerStep == 0) this.game.step();
}

function ArrowListener() {
    this.onKeyDown = function() {
        switch(Key.getCode()) {
            case Key.UP:
                if(this.game.direction == 2) break;
                this.game.direction = 0;
                break;
            case Key.RIGHT:
                if(this.game.direction == 3) break;
                this.game.direction = 1;
                break;
            case Key.DOWN:
                if(this.game.direction == 0) break;
                this.game.direction = 2;
                break;
            case Key.LEFT:
                if(this.game.direction == 1) break;
                this.game.direction = 3;
                break;
            case Key.SPACE:
                
                this.game.start();
                _root.onEnterFrame = playGame;
                break;
                
            case Key.HOME:
                this.game.barrierFrequency = ( this.game.barrierFrequency > 0 ) ? 0 : .05;
                break;
            
            
        }
               
    }
}


listener = new ArrowListener();
listener.game = this.game;

Key.addListener(listener);