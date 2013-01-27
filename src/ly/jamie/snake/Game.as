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

    public var debug: Function = function():void{};

    function Game(parentMC:MovieClip, boardWidth:Number, boardHeight:Number) {
        debug("Initializing Game");

        this.snake = new Array();
        this.defaultSegment = CreateSnakeSegment(parentMC, 10, 10);
        this.defaultPellet = CreatePellet(parentMC, 5, 5);
        this.defaultBarrier = CreateBarrier(parentMC, 10, 10);
        debug("\tDefault snake segment: " + this.defaultSegment + " Default pellet: " + this.defaultPellet);
        this.parentMC = parentMC;

        this.wrapAround = true;


        this.startingLength = 1;
        this.startPosition = new Point(Math.floor(boardWidth / 2), Math.floor(boardHeight / 2));

        debug("\tDefault starting position: " + this.startPosition.toString());
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

        //debug("A: " +this.board + this.mcs);

        for(var i:Number = 0; i < boardWidth; i ++) {
            this.board[i] = new Array(boardHeight);
            this.mcs[i] = new Array(boardHeight);
            for(var j:Number=0; j < boardHeight; j ++) {
                this.board[i][j] = EMPTY;
                this.mcs[i][j] = null;
            }
        }

        debug("\tBoard Initialized");
    }

    public function clearPosition(x:Number, y:Number):void {
        debug("Clearing board position " + x +  ", " + y + " val = " + this.board[x][y]);
        this.board[x][y] = EMPTY;
        if ( this.mcs[x][y] != null ) {
            this.mcs[x][y].removeMovieClip();
            this.mcs[x][y] = null;
        }
    }

    public function addBarriers():void {
        this.barrierCount = 0;
        this.barriers = new Array();
        var maxBarriers:Number = this.barrierFrequency * this.boardWidth * this.boardHeight;
        var pt:Point;

        if ( this.barriers != null ) {
            while ( this.barriers.length > 0 ) {
                pt = this.barriers[0];
                this.clearPosition(pt.x, pt.y);
                this.barriers.shift();
            }
        }

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


        debug("\tAdded " + barrierCount + " of " + maxBarriers + " barriers.");

        for(var i:Number=0; i < this.barriers.length; i ++ ) {
            pt = this.barriers[i];
            var barrierName:String = "barrier" + i; // depth
            var mc:MovieClip = CreateBarrier(this.parentMC, this.barrier.width, this.barrier.height);
            mc.x = pt.x * this.snakeSegment.width;
            mc.y = pt.y * this.snakeSegment.height;

            this.mcs[pt.x][pt.y] = mc;
        }

        debug("Barrier size: Width=" + this.barrier.width + " Height=" + this.barrier.height);
    }

    public function printBoard():void {
        var str:String = ""
        for( var i:Number = 0; i < this.board.length; i ++ ) { 
            str = str + this.board[i].join("") + "\n";
        }
        debug(str);
    }

    public function removePellet():void {
        debug("Remove Pellet");
        var pell:MovieClip = this.pellets[0];

        debug("\tlocation: " + pell.toString());

        this.board[pell.x][pell.y] = EMPTY;

        debug("\tmc: " + this.mcs[pell.x][pell.y]);

        this.mcs[pell.x][pell.y].removeMovieClip();
        this.mcs[pell.x][pell.y] = null;

        this.pellets.shift();
    }

    public function addPellet():void {
        debug("AddPellete");
        do {
            x = Math.floor(Math.random() * this.boardWidth);
            y = Math.floor(Math.random() * this.boardHeight);

            debug("\tattempting at location: " + x + ", " + y + " board = " + this.board[x][y]);
        } while ( this.board[x][y] != EMPTY );

        var pt:Point = new Point(x, y);

        debug("\tlocation: " + pt.toString());

        this.board[x][y] = PELLET;

        var pelletName:String = "pellet"; // depth


        this.pellet.duplicateMovieClip(pelletName, 1); // depth
        debug("\tname: " + pelletName + " mc: " + this.pellet);

        this.mcs[x][y] = this.parentMC[pelletName];

        this.mcs[x][y].x = x * this.snakeSegment.width;
        this.mcs[x][y].y = y * this.snakeSegment.height;

        debug("\tmc: " + this.mcs[x][y]);

        this.pellets.push(pt);

        // depth
    }

    public function start():void {
        debug("Game Start");



        debug("\tInitialize board to "  + EMPTY);
        for(var i:Number = 0; i < this.boardWidth; i ++) {
            for(var j:Number = 0; j < this.boardHeight; j ++) {
                this.clearPosition(i, j);
            }
        }



        // debug("\tBoard:");
        // this.printBoard();

        debug("\tBuilt board");
        this.length = 1;
        this.pellets = new Array();
        this.isGameOver = false;
        this.direction = this.startingDirection;
        this.board[this.startPosition.x][this.startPosition.y] = SNAKE;

        var firstSegment: Point = new Point(this.startPosition.x, this.startPosition.y);
        this.snake.push(firstSegment);

        debug("\tFirst segment: " + firstSegment.toString());

        this.snakeSegment = this.defaultSegment;
        this.pellet = this.defaultPellet;
        this.barrier = this.defaultBarrier;

        //this.depth = 100;
        this.addBarriers();
        throw new Error("Added barriers");
 
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

        debug("\tSnake segment created.");

        this.isGameOver = false;
    }

    public function popSnakeSegment ():void { 
        debug("Popping Snake Segment");

        if ( this.snake.length < 1 ) {
            debug("\tSnake has no length");
            return;
        }

        var end:MovieClip = this.snake[this.snake.length-1];
        debug("\tLast segment positon: " + end.toString());
        if ( this.board[end.x][end.y] == SNAKE ) this.board[end.x][end.y] = EMPTY;

        debug("\tRemoving clip: " + this.mcs[end.x][end.y]);
        this.mcs[end.x][end.y].removeMovieClip();
        this.mcs[end.x][end.y] = null;

        var len:Number = this.snake.length;
        this.snake.pop();

        debug("\tSnake length before: " + len  + " afteR: " + this.snake.length);
    }

    public function createSnakeSegment(x:Number, y:Number):void {
        debug("Create Snake Segment");

        var pt:Point = new Point(x, y);

        debug("\tNew segment at point: " + pt.toString());

        this.snake.unshift(pt);


        debug("\tCreating snake segment at " + pt.toString());
        //segmentName = "segment" + this.depth;
        var segmentName:String = "segment";
        //this.snakeSegment.duplicateMovieClip(segmentName, this.depth);
        this.snakeSegment.duplicateMovieClip(segmentName, 0);
        //debug("\tdepth: " + this.depth);

        var mc:MovieClip = this.parentMC[segmentName];

        debug("\tDuplicated clip: " + this.snakeSegment + " to " + mc);

        mc.x = x * mc.height; 
        mc.y = y * mc.width;

        debug("\tMovieclip moved to: (" + mc.x + ", " + mc.y + ")");

        this.mcs[x][y] = mc;

        this.board[pt.x][pt.y] = SNAKE;


        debug("\tMovieclip " + mc + " stored at: " + this.mcs[x][y]);

        //this.depth ++;
    }

    public function step():void {
        debug("Step");

        if ( this.isGameOver ) {
            //this.step = undefined;
            debug("\tGame Over.");
            return;
        }

        if ( !this.shouldGrow ) {
            // move from back to front
            debug("\tDo Not grow");
            this.popSnakeSegment();
        }
        else {
            this.shouldGrow = false
        }

        var position: Point = this.getNextPosition();
        if ( position != null ) {
            debug("\tSnake moving into position " + position.toString());

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
            debug("\tGame will be over next step.");
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
        debug("GetNextPosition");
        var pos: Point = new Point(this.snake[0].x, this.snake[0].y);

        debug("\tPrevious position: " + pos.toString());

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

        debug("\tDirection: " + this.direction);

        if(this.wrapAround) {
            if ( pos.x < 0 ) pos.x = this.boardWidth - 1;
            else if (pos.x >=this.boardWidth) pos.x = 0;
            else if ( pos.y < 0 ) pos.y = this.boardHeight - 1;
            else if ( pos.y >= this.boardHeight ) pos.y = 0;
        }
        else if ( pos.x < 0 || pos.y < 0  || pos.y >= this.boardHeight || pos.x >= this.boardWidth) return null;

        debug("\tNext position: " + pos.toString());

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
        mcBarrier.visible = true;

        return mcBarrier;
    }

    private function CreatePellet(mc:MovieClip, width:Number, height:Number): MovieClip {
        var mcPellet: MovieClip = new MovieClip();
        mc.addChild( mcPellet );

        for(var obj: Object in mc) {
            debug("\t" + obj);
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

        debug("\tMC: " + mc + " CreatePellet: " + mcPellet);

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
