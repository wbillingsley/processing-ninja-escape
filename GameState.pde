/**
 * Our GameState's responsibility is store store the state of the game!
 */
class GameState {
  
  // What number maps to what sort of tile. eg 1 -> Floor tile
  HashMap<Integer, Tile> tiles;
  
  // grid of tiles
  int[][] map = new int[][] {
    { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    { 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1 },
    { 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1 },
    { 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1 },
    { 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
    { 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1 },
    { 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1 },
    { 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1 },
    { 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1 },
    { 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1 },
    { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }
  };
  int h = map.length;
  int w = map[0].length;
  
  // At the moment, we have one monster in the game
  Monster m;
  
  // At the moment, we have one monster in the game
  Hero hero;  
  
  /**
   * The constructor for our GameState. This sets it up when you call "new GameState()"
   */
  GameState() {
    tiles = new HashMap<Integer, Tile>();
    tiles.put(0, new FloorTile());
    tiles.put(1, new WallTile()); 
    
    m = new Monster(7,3);
    
    hero = new Hero(4, 4, 0);
  }
  
  /**
   * Is the square at x,y passable?
   */
  boolean isPassable(int x, int y) {
    return tiles.get(map[y][x]).isPassable();    
  }
  
  /**
   * Draws the GameState on the screen.
   * It delegates the drawing to the items that make up the game state -- first the tiles, 
   * and then the monster
   */
  void draw() {
    for (int x=0; x < w; x++) {
      for (int y=0; y < h; y++) {
        tiles.get(map[y][x]).draw(x, y);           
      }
    }    
    
    m.draw(this);
    hero.draw(this);
  }
  
  boolean canMove(int x, int y, int direction) {
    int nextX, nextY;
      switch(direction) {
        case 0:
          nextX = x;
          nextY = y - 1;
          break;  
        case 1:
          nextX = x + 1;
          nextY = y;
          break;
        case 2: 
          nextX = x;
          nextY = y + 1;
          break;  
        case 3:
          nextX = x - 1;
          nextY = y;
          break;  
        default:
          throw new IllegalStateException("Somehow we have a direction that is not n, s, e, or w");
      }
      
      return isPassable(nextX, nextY);   
  }  
  
}