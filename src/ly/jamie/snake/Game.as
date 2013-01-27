package ly.jamie.snake {
  import flash.display.MovieClip;

  public class Game extends MovieClip {

    // compass
    //          0
    //   3            1
    //          2

    public var NORTH:Number = 0;
    public var EAST:Number = 1;
    public var SOUTH:Number = 2;
    public var WEST:Number = 3;

    public var EMPTY:Number = 0;
    public var SNAKE:Number = 1;
    public var BARRIER:Number = 2;
    public var PELLET:Number = 3;

    private var snake:Array;
    private var defaultSegment:MovieClip;
    private var defaultPellet:MovieClip;
    private var defaultBarrier:MovieClip;
    private var parentMC:MovieClip;
    private var wrapAround: Boolean;
    private var startingLength:Number;
    private var startPosition:Point;
    private var startingDirection:Number;
    private var length:Number;
    private var boardWidth:Number;
    private var boardHeight:Number;
    private var clock:Number;
    private var pellet:MovieClip;
    private var pellets:Array;
    private var pelletFrequency:Number;
    private var pelletLifespan:Number;
    private var pelletCounter:Number;
    private var pelletClock:Number;
    private var barrier:MovieClip;
    private var barriers:Array;
    public var barrierFrequency:Number;
    private var barrierCount:Number;
    private var segment:MovieClip;
    private var board:Array;
    private var mcs:Array;
    private var snakeSegment: MovieClip;
    private var isGameOver: Boolean;
    private var direction: Number;
    private var shouldGrow: Boolean;


    function Game(parentMC:MovieClip, boardWidth:Number, boardHeight:Number) {
        trace("Initializing Game");

        this.snake = new Array();
        this.defaultSegment = CreateSnakeSegment(parentMC, 10, 10);
        this.defaultPellet = CreatePellet(parentMC, 5, 5);
        this.defaultBarrier = CreateBarrier(parentMC, 10, 10);
        trace("\tDefault snake segment: " + this.defaultSegment + " Default pellet: " + this.defaultPellet);
        this.parentMC = parentMC;

        this.wrapAround = true;


        this.startingLength = 1;
        this.startPosition = new Point(Math.floor(boardWidth / 2), Math.floor(boardHeight / 2));

        trace("\tDefault starting position: " + this.startPosition.toString());
        this.startingDirection = WEST; //
        this.length = 1;
        this.boardWidth = boardWidth;
        this.boardHeight = boardHeight;

        this.clock = 0;

        this.pelletFrequency = 40; // every 10 steps
        this.pelletLifespan = 30; // disappears 10 steps after creation
        this.pelletCounter = 0;

        this.barrierFrequency = .05;

        this.segment = null;

        this.board = new Array(boardWidth);
        this.mcs = new Array(boardWidth);

        //trace("A: " +this.board + this.mcs);

        for(var i:Number = 0; i < boardWidth; i ++) {
            this.board[i] = new Array(boardHeight);
            this.mcs[i] = new Array(boardHeight);
            for(var j:Number=0; j < boardHeight; j ++) {
                this.board[i][j] = EMPTY;
                this.mcs[i][j] = null;
            }
        }

        trace("\tBoard Initialized");
    }

    public function clearPosition(x:Number, y:Number):void {
        trace("Clearing board position " + x +  ", " + y + " val = " + this.board[x][y]);
        this.board[x][y] = EMPTY;
        if ( this.mcs[x][y] != null ) {
            this.mcs[x][y].removeMovieClip();
            this.mcs[x][y] = null;
        }
    }

    public function addBarriers():void {
        trace("AddBarriers");
        this.barrierCount = 0;
        this.barriers = new Array();
        var maxBarriers:Number = this.barrierFrequency * this.boardWidth * this.boardHeight;

        if ( this.barriers != null ) {
            while ( this.barriers.length > 0 ) {
                var pt:Point = this.barriers[0];
                this.clearPosition(pt.x, pt.y);
                this.barriers.shift();
            }
        }

        trace("\tBoard before:") 

        this.printBoard();

        while(barrierCount < maxBarriers) {
            var x:Number = Math.floor(Math.random() * this.boardWidth);
            var y:Number = Math.floor(Math.random() * this.boardHeight);

            if ( this.board[x][y] == EMPTY ) {
                barrierCount ++ ;
                this.board[x][y] = BARRIER;
                this.barriers.push( new Point(x, y) );
            }

            if ( Math.random() < .01 ) break;
        }


        trace("\tBoard after:") 

        this.printBoard();

        trace("\tAdded " + barrierCount + " of " + maxBarriers + " barriers.");
        trace("\tDuplicating barrier: " + this.barrier);

        for(var i:Number=0; i < this.barriers.length; i ++ ) {
            pt = this.barriers[i];
            var barrierName:String = "barrier" + i; // depth
            this.barrier.duplicateMovieClip(barrierName, i)

            var mc:MovieClip = this.parentMC[barrierName];

            mc.x = pt.x * this.snakeSegment.width;
            mc.y = pt.y * this.snakeSegment.height;

            this.mcs[pt.x][pt.y] = mc;


            trace("\tAdding barrier " + mc + " at " + pt.toString());
        }
    }

    public function printBoard():void {
        var str:String = ""
        for( var i:Number = 0; i < this.board.length; i ++ ) { 
            str = str + this.board[i].join("") + "\n";
        }
        trace(str);
    }

    public function removePellet():void {
        trace("Remove Pellet");
        var pell:MovieClip = this.pellets[0];

        trace("\tlocation: " + pell.toString());

        this.board[pell.x][pell.y] = EMPTY;

        trace("\tmc: " + this.mcs[pell.x][pell.y]);

        this.mcs[pell.x][pell.y].removeMovieClip();
        this.mcs[pell.x][pell.y] = null;

        this.pellets.shift();
    }

    public function addPellet():void {
        trace("AddPellete");
        do {
            x = Math.floor(Math.random() * this.boardWidth);
            y = Math.floor(Math.random() * this.boardHeight);

            trace("\tattempting at location: " + x + ", " + y + " board = " + this.board[x][y]);
        } while ( this.board[x][y] != EMPTY );

        var pt:Point = new Point(x, y);

        trace("\tlocation: " + pt.toString());

        this.board[x][y] = PELLET;

        var pelletName:String = "pellet"; // depth


        this.pellet.duplicateMovieClip(pelletName, 1); // depth
        trace("\tname: " + pelletName + " mc: " + this.pellet);

        this.mcs[x][y] = this.parentMC[pelletName];

        this.mcs[x][y].x = x * this.snakeSegment.width;
        this.mcs[x][y].y = y * this.snakeSegment.height;

        trace("\tmc: " + this.mcs[x][y]);

        this.pellets.push(pt);

        // depth
    }

    public function start():void {
        trace("Game Start");



        trace("\tInitialize board to "  + EMPTY);
        for(var i:Number = 0; i < this.boardWidth; i ++) {
            for(var j:Number = 0; j < this.boardHeight; j ++) {
                this.clearPosition(i, j);
            }
        }



        trace("\tBoard:");
        this.printBoard();

        trace("\tBuilt board");
        this.length = 1;
        this.pellets = new Array();
        this.isGameOver = false;
        this.direction = this.startingDirection;
        this.board[this.startPosition.x][this.startPosition.y] = SNAKE;

        var firstSegment: Point = new Point(this.startPosition.x, this.startPosition.y);
        this.snake.push(firstSegment);

        trace("\tFirst segment: " + firstSegment.toString());

        this.snakeSegment = this.defaultSegment;
        this.pellet = this.defaultPellet;
        this.barrier = this.defaultBarrier;

        //this.depth = 100;
        this.addBarriers();
 
        while ( this.snake.length > 1 ) {
          this.popSnakeSegment(); 
        }
        this.createSnakeSegment(this.startPosition.x, this.startPosition.y);

        var w:Number = this.boardWidth * this.snakeSegment.width;
        var h:Number = this.boardHeight * this.snakeSegment.height;
        with(this.parentMC.graphics) {
            lineStyle(2, 0x000000, 80);
            moveTo(w, h);
            lineTo(0, h);
            lineTo(0, 0);
            lineTo(w, 0);
            lineTo(w, h);
        }

        trace("\tSnake segment created.");

        this.isGameOver = false;
    }

    public function popSnakeSegment ():void { 
        trace("Popping Snake Segment");

        if ( this.snake.length < 1 ) {
            trace("\tSnake has no length");
            return;
        }

        var end:MovieClip = this.snake[this.snake.length-1];
        trace("\tLast segment positon: " + end.toString());
        if ( this.board[end.x][end.y] == SNAKE ) this.board[end.x][end.y] = EMPTY;

        trace("\tRemoving clip: " + this.mcs[end.x][end.y]);
        this.mcs[end.x][end.y].removeMovieClip();
        this.mcs[end.x][end.y] = null;

        var len:Number = this.snake.length;
        this.snake.pop();

        trace("\tSnake length before: " + len  + " afteR: " + this.snake.length);
    }

    public function createSnakeSegment(x:Number, y:Number):void {
        trace("Create Snake Segment");

        var pt:Point = new Point(x, y);

        trace("\tNew segment at point: " + pt.toString());

        this.snake.unshift(pt);


        trace("\tCreating snake segment at " + pt.toString());
        //segmentName = "segment" + this.depth;
        var segmentName:String = "segment";
        //this.snakeSegment.duplicateMovieClip(segmentName, this.depth);
        this.snakeSegment.duplicateMovieClip(segmentName, 0);
        trace("\tdepth: " + this.depth);

        var mc:MovieClip = this.parentMC[segmentName];

        trace("\tDuplicated clip: " + this.snakeSegment + " to " + mc);

        mc.x = x * mc.height; 
        mc.y = y * mc.width;

        trace("\tMovieclip moved to: (" + mc.x + ", " + mc.y + ")");

        this.mcs[x][y] = mc;

        this.board[pt.x][pt.y] = SNAKE;


        trace("\tMovieclip " + mc + " stored at: " + this.mcs[x][y]);

        //this.depth ++;
    }

    public function step():void {
        trace("Step");

        if ( this.isGameOver ) {
            //this.step = undefined;
            trace("\tGame Over.");
            return;
        }

        if ( !this.shouldGrow ) {
            // move from back to front
            trace("\tDo Not grow");
            this.popSnakeSegment();
        }
        else {
            this.shouldGrow = false
        }

        var position: Point = this.getNextPosition();
        if ( position != null ) {
            trace("\tSnake moving into position " + position.toString());

            switch( this.board[position.x][position.y] ) { 
                case PELLET:
                    // pellet
                    this.removePellet();
                    this.shouldGrow = true;
                    break;
                case SNAKE:
                case BARRIER:
                    this.isGameOver = true;
                    return;

            }

            this.createSnakeSegment ( position.x, position.y );
        } 
        else {
            trace("\tGame will be over next step.");
            this.isGameOver = true;
        }

        if ( this.clock % this.pelletFrequency == 0 ) {
            this.addPellet();
            this.pelletClock = 0;
        } else {
            this.pelletClock++;
        }

        if ( this.pelletClock >= this.pelletLifespan ) {
            this.removePellet();
        }

        this.clock ++;
    }

    public function getNextPosition():Point {
        trace("GetNextPosition");
        var pos: Point = new Point(this.snake[0].x, this.snake[0].y);

        trace("\tPrevious position: " + pos.toString());

        switch(this.direction) {
            case EAST:
                pos.x ++; break;
            case NORTH:
                pos.y --; break;
            case SOUTH:
                pos.y ++; break;
            case WEST:
                pos.x --; break;
        }

        trace("\tDirection: " + this.direction);

        if(this.wrapAround) {
            if ( pos.x < 0 ) pos.x = this.boardWidth - 1;
            else if (pos.x >=this.boardWidth) pos.x = 0;
            else if ( pos.y < 0 ) pos.y = this.boardHeight - 1;
            else if ( pos.y >= this.boardHeight ) pos.y = 0;
        }
        else if ( pos.x < 0 || pos.y < 0  || pos.y >= this.boardHeight || pos.x >= this.boardWidth) return null;

        trace("\tNext position: " + pos.toString());

        return pos; 
    }

    public function remove():void {
    }

    public function grow():void {
        this.length++;
        this.shouldGrow = true;
    }

    public function render():void {
   
    }

    private function CreateSnakeSegment(mc:MovieClip, width:Number, height:Number):MovieClip {
        var segment: MovieClip = new MovieClip();
        mc.addChild(segment);

        var halfwidth:Number = Math.floor(width / 2);
        var halfheight:Number = Math.floor(height / 2);
        with ( segment.graphics ) {
            lineStyle(1, 0x000000, 100);
            moveTo(halfwidth, halfheight);
            beginFill(0x00FF00, 100);
            lineTo(-halfwidth, halfheight);
            lineTo(-halfwidth, -halfheight);
            lineTo(halfwidth, -halfheight);
            lineTo(halfwidth, halfheight);
            endFill();
        }
        segment.visible = false;

        return segment;
    }

    private function CreateBarrier(mc:MovieClip, width:Number, height:Number):MovieClip {
        var mcBarrier: MovieClip = new MovieClip();
        mc.addChild(mcBarrier);

        var halfwidth:Number = Math.floor(width / 2);
        var halfheight:Number  = Math.floor(height / 2);
        with ( mcBarrier.graphics ) {
            lineStyle(1, 0x000000, 100);
            moveTo(halfwidth, halfheight);
            beginFill(0x990000, 100);
            lineTo(-halfwidth, halfheight);
            lineTo(-halfwidth, -halfheight);
            lineTo(halfwidth, -halfheight);
            lineTo(halfwidth, halfheight);
            endFill();
        }
        mcBarrier.visible = false;

        return mcBarrier;
    }

    private function CreatePellet(mc:MovieClip, width:Number, height:Number): MovieClip {
        var mcPellet: MovieClip = new MovieClip();
        mc.addChild( mcPellet );

        for(var obj: Object in mc) {
            trace("\t" + obj);
        }

        var halfwidth:Number = Math.floor(width / 2);
        var halfheight:Number  = Math.floor(height / 2);

        with ( mcPellet.graphics ) {
            lineStyle(1, 0xFF0000, 100);
            beginFill(0xFF0000);
            moveTo(halfwidth, halfheight);
            lineTo(-halfwidth, halfheight);
            lineTo(-halfwidth, -halfheight);
            lineTo(halfwidth, -halfheight);
            lineTo(halfwidth, halfheight);
            endFill();
        }

        mcPellet.x = 10;
        mcPellet.y = 10;
        mcPellet.visible = false;

        trace("\tMC: " + mc + " CreatePellet: " + mcPellet);

        return mcPellet;
    }

    public function getDirection(): Number {
      return this.direction;
    }
    public function setDirection(dir:Number): void {
      this.direction = dir;
    }

  }
}
