interface Tile {
  static int spriteHeight = 64;
  
  boolean isPassable();
  
  void draw(int x, int y);
}

class FloorTile implements Tile {
  PShape shape;
  FloorTile() {
    shape = createShape(RECT, 0, 0, spriteHeight, spriteHeight);
    shape.setFill(color(60, 60, 60));
  }
  
  boolean isPassable() {
    return true;
  }
  
  void draw(int x, int y) {
    shape(shape, x * spriteHeight, y * spriteHeight);
  }
}

class WallTile implements Tile {
  PShape shape;
  WallTile() {
    shape = createShape(RECT, 0, 0, spriteHeight, spriteHeight);
    shape.setFill(color(100, 100, 80));
  }
  
  boolean isPassable() {
    return false;
  }
  
  void draw(int x, int y) {
    shape(shape, x * spriteHeight, y * spriteHeight);
  }
}