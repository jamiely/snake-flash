package ly.jamie.snake {

  class Point {
    function Point(x, y) {
      this.x = x;
      this.y = y;
    }
    public function toString(): String {
      return "(" + this.x + ", " + this.y + ")";
    }
  }
}

