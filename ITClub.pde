
int oneTile = 64;
int halfTile = oneTile / 2;
int quarterTile = oneTile / 4;
int eighthTile = oneTile / 8;

boolean running = true;
boolean spoilerPaths = false;
boolean monstersActive = true;
boolean manualControl = true;
boolean showRoutes = false;
boolean routesConsiderMonsters = false;

int numPaths = 4;
int numMonsters = 2;

GameMap gameMap = new GameMap(); 
BlobMonster[] monsters = new BlobMonster[0]; 

Hero hero = new Hero();

class Hero {
  
  int x = 0;
  int y = 0;
  Move move = new Move(Move.IDLE);
  RouteFinder routeFinder = new RouteFinder();
  
  /** 
    * This is the function that controls the ninja's movements. Right now, you control them.
    * But you're going to write an AI script for it...
    */
  void act(Move lastMove) {
    // YOUR CODE GOES HERE!
  }
  
  /*
   *  Manual control...
   */ 
  void manualControl(Move lastMove) {
    if (keyPressed) {
      switch(key) {
        case 'w': moveNorth(); break;
        case 's': moveSouth(); break;
        case 'd': moveEast(); break;
        case 'a': moveWest(); break;
        default: move = new Move(Move.IDLE);        
      }      
    } else {
      move = new Move(Move.IDLE);
    }    
  }
  
  void moveNorth() {
    move(GameMap.NORTH);
  }

  void moveSouth() {
    move(GameMap.SOUTH);
  }

  void moveEast() {
    move(GameMap.EAST);
  }

  void moveWest() {
    move(GameMap.WEST);
  }
  
  boolean canMoveSouth() { 
    return canMove(GameMap.SOUTH);  
  }

  boolean canMoveNorth() { 
    return canMove(GameMap.NORTH);  
  }

  boolean canMoveEast() { 
    return canMove(GameMap.EAST);  
  }

  boolean canMoveWest() { 
    return canMove(GameMap.WEST);  
  }

  
  void move(int dir) { 
    if (gameMap.canMove(dir, x, y)) {
      move = new Move(dir); 
    } else {
      move = new Move(Move.IDLE);
    }    
  }
  
  boolean canMove(int dir) {
    return gameMap.canMove(dir, x, y);
  }
  
  void draw() {
    if (move.isComplete()) { 
      x += move.afterDx();
      y += move.afterDy();
      routeFinder.reset();
      routeFinder.check(GameMap.TilesWide - 1, GameMap.TilesHigh - 1, 0); 
      Move lastMove = move;
      move = new Move(Move.IDLE);

      if (running) {
        if (manualControl) { 
          manualControl(lastMove); 
        } else act(lastMove);
      }
    }
    
    // Draw the routeFinder's numbers
    if (showRoutes) routeFinder.draw();

    // highlight active square
    fill(0, 0, 255, 50);
    stroke(0, 0, 255, 0);
    rect(tilesToPixels(x), tilesToPixels(y), oneTile, oneTile);        
    
    fill(50, 50, 100);
    stroke(70, 70, 100);

    // head
    ellipse(
      tilesToPixels(x) + halfTile + move.dx(), 
      tilesToPixels(y) + halfTile + move.dy(), 
      halfTile, halfTile
    );
    
    // mask opening
    fill(220, 200, 200);
    stroke(70, 70, 100);
    arc(
      tilesToPixels(x) + halfTile + move.dx(), 
      tilesToPixels(y) + quarterTile + eighthTile + move.dy(), 
      halfTile, halfTile,
      0.5, PI - 0.5, CHORD    
    );
    
    // eyes
    fill(20, 20, 20);
    stroke(20, 20, 20);
    ellipse(
      tilesToPixels(x) + move.dx() + halfTile - eighthTile, 
      tilesToPixels(y) + move.dy() + halfTile + 2, 
      2, 2
    );
    ellipse(
      tilesToPixels(x) + move.dx() + halfTile + eighthTile, 
      tilesToPixels(y) + move.dy() + halfTile + 2, 
      2, 2
    );    
   
  }    
  
}


// Creates some monsters
void setupMonsters() {
  monsters = new BlobMonster[numMonsters];
  for (int i = 0; i < numMonsters; i++) {
    BlobMonster m = new BlobMonster();
    m.findRandomTile();
    monsters[i] = m;
  }
}

void setup() {
  size(1024, 768, P2D);
  orientation(LANDSCAPE);
  
  gameMap.makePaths();
  if (spoilerPaths) gameMap.spoilerPaths();
  if (monstersActive) setupMonsters();
}


float tilesToPixels(float x) {
  return oneTile * x;
}

void draw() {  
    //background(204);
    gameMap.draw();
    hero.draw();
    for (BlobMonster m : monsters) { 
      m.draw();
    }
}

/** A Move action that the player or a monster can take */
public class Move {
  static final int IDLE = 0;
  
  long start;
  int direction;
  float duration = 750.0;
  
  public Move(int dir) {
    this.direction = dir;
    this.start = millis();
  }
  
  public float dx() {
    float dt = oneTile * (millis() - start)/duration;        
    switch(direction) {
      case GameMap.EAST: return dt;
      case GameMap.WEST: return -dt;
      default: return 0;
    }
  }
  
  public float dy() {
    float dt = oneTile * (millis() - start)/duration;
    switch(direction) {
      case GameMap.SOUTH: return dt;
      case GameMap.NORTH: return -dt;
      default: return 0;
    }
  }  
  
  public int afterDx() { 
    return gameMap.targetX(direction, 0, 0);  
  }
  
  public int afterDy() { 
    return gameMap.targetY(direction, 0, 0);  
  }
  
  public boolean isComplete() { 
    return direction == Move.IDLE || millis() - start >= duration;  
  }
}

/** 
  * We've put our monsters into a little class. This keeps their code nicely contained.
  */
public class BlobMonster {
   
  int x = 0;
  int y = 0;
  Move move = new Move(Move.IDLE);
  
  float blobWidth;
  float blobHeight;
  
  void findRandomTile() {
    int tx, ty;
    do {
      tx = (int)random(GameMap.TilesWide);
      ty = (int)random(GameMap.TilesHigh);
    } while (tx == 0 || ty == 0 || gameMap.gameMap[ty][tx] == 0);
    x = tx;
    y = ty;
  }
  
  int randomMove() { 
    ArrayList<Integer> directions = new ArrayList<Integer>();
    for (int i : new int[] { GameMap.NORTH, GameMap.SOUTH, GameMap.EAST, GameMap.WEST }) {
      if (gameMap.canMove(i, x, y)) {
        directions.add(i);
      }
    }
    if (directions.size() > 0) {
      return directions.get((int)random(directions.size()));  
    } else {
      // We can't move in any direction, so just idle.
      return 1;
    }
  }
  
  void act() {
    x += move.afterDx();
    y += move.afterDy();
    if (move.direction != Move.IDLE && gameMap.canMove(move.direction, x, y)) {
      move = new Move(move.direction);
    } else {
      move = new Move(randomMove());
    }      
  }
  
  void draw() {
    long time = millis();
    float theta = time * 6.3 / 1000;
    
    if (move.isComplete()) { 
      act();
    }
    
    if (running) {
      blobWidth = (quarterTile + eighthTile) + (eighthTile * sin(theta));
      blobHeight = (quarterTile + eighthTile) + (eighthTile * cos(theta));
    }

    // highlight active square
    fill(255, 0, 0, 100);
    stroke(95, 0, 0, 0);
    rect(tilesToPixels(x), tilesToPixels(y), oneTile, oneTile);    

    // draw the blob
    fill(200, 50, 50);
    stroke(200, 70, 70);
    ellipse(
      tilesToPixels(x) + halfTile + move.dx(), 
      tilesToPixels(y) + halfTile + move.dy(), 
      blobWidth, blobHeight
    );
    
  }
  
}

// Checks whether there are any monsters in the specified square
boolean monstersAt(int x, int y) {
  for (BlobMonster m : monsters) {
    if (m.x == x && m.y == y) return true;
  } 
  return false;
}

public class RouteFinder {
  int x = GameMap.TilesWide - 1;
  int y = GameMap.TilesHigh - 1;
  
  int[][] goalDist = new int[GameMap.TilesHigh][GameMap.TilesWide];

  public RouteFinder() {
    reset();
  }
  
  void reset() {
    for (int y = 0; y < GameMap.TilesHigh; y++) {
      for (int x = 0; x < GameMap.TilesWide; x++) {
        goalDist[y][x] = MAX_INT;
      }
    }    
  }
  
  void check(int x, int y, int dist) {
    goalDist[y][x] = dist;
    for (int move : new int[] { GameMap.NORTH, GameMap.SOUTH, GameMap.EAST, GameMap.WEST }) {
      int tx = gameMap.targetX(move, x, y);
      int ty = gameMap.targetY(move, x, y);
      if(
        gameMap.canMove(move, x, y) &&
        goalDist[ty][tx] > dist + 1 && 
        !(routesConsiderMonsters && monstersAt(tx, ty))
      ) {
        check(tx, ty, dist + 1);  
      }          
    }   
  }
  
  void draw() {
    for (int y = 0; y < GameMap.TilesHigh; y++) {
      for (int x = 0; x < GameMap.TilesWide; x++) {
        int d = goalDist[y][x];
        if (d > 0 && d < MAX_INT) {
          fill(color(80, 80, 80));
          textSize(20);
          text("" + d, tilesToPixels(x) + eighthTile, tilesToPixels(y) + halfTile);
        }
      }
    }    
  }
}

/**
 * We've put the game map into its own "class". This is a way 
 * of grouping variables and functions together.
 */
public class GameMap {
  static final int TilesWide = 16;
  static final int TilesHigh = 12;
  
  static final int LAVA = 0;
  static final int FLOOR = 1;  
  static final int GOAL = 2;  
  
  static final int NORTH = 1;
  static final int SOUTH = 2;
  static final int EAST = 3;
  static final int WEST = 4;
  
  int[][] gameMap = new int[TilesHigh][TilesWide];
    
  // Let's have a nice bubbling lava background
  Lava lava = new Lava();
  
  public void makePaths() { 
    for (int i = 0; i < numPaths; i++) {
      makePath();  
    }
    gameMap[TilesHigh - 1][TilesWide - 1] = GOAL;
    gameMap[TilesHigh - 2][TilesWide - 1] = FLOOR;
    gameMap[TilesHigh - 1][TilesWide - 2] = FLOOR;
    gameMap[TilesHigh - 2][TilesWide - 2] = FLOOR;
  }
  
  public void spoilerPaths() {
    for (int x = 0; x < TilesWide; x++) {
      gameMap[TilesHigh/2][x] = FLOOR;  
    }
    for (int y = 0; y < TilesHigh; y++) {
      gameMap[y][TilesWide/2] = FLOOR;  
    }
  }
  
  // We're going to make the paths programmatically -- the map
  // will be different every time!
  public void makePath() { 
    int x = 0;
    int y = 0;
    
    while (x < TilesWide - 2 || y < TilesHigh - 2) {
      if (y < TilesHigh - 1 && random(2) > 1) {
        int run = (int)(random(TilesHigh - y - 1)/2) * 2;
        for (int i = 0; i < run; i ++) {
          gameMap[y + i][x] = 1;
        }
        y = y + run;
      } else {
        int run = (int)(random(TilesWide - x - 1)/2) * 2;
        for (int i = 0; i < run; i ++) {
          gameMap[y][x + i] = 1;
        }
        x = x + run;        
      }
    }
    
  }
  
  public int targetX(int dir, int x, int y) {
    switch(dir) {
      case EAST: return x + 1;
      case WEST: return x - 1;
      default: return x; 
    }
  }

  public int targetY(int dir, int x, int y) {
    switch(dir) {
      case NORTH: return y - 1;
      case SOUTH: return y + 1;
      default: return y; 
    }
  }

  public boolean canMove(int dir, int x, int y) {
    int tx = targetX(dir, x, y);
    int ty = targetY(dir, x, y);
    return (tx >= 0 && tx < TilesWide && ty >= 0 && ty < TilesHigh && gameMap[ty][tx] != LAVA); 
  }

  public void draw() {
    lava.draw();
    for (int y = 0; y < TilesHigh; y = y + 1) {
      for (int x = 0; x < TilesWide; x = x + 1) {
        int tileValue = gameMap[y][x];
        switch (tileValue) {
          case FLOOR: 
            drawFloorTile(x, y); break;
          case GOAL: 
            drawGoalTile(x, y); break;          
        }
      }
    } 
  }
  
  void drawFloorTile(float x, float y) {
    fill(color(20, 20, 20));
    stroke(color(80,80,80));
    rect(tilesToPixels(x), tilesToPixels(y), oneTile, oneTile);
  }

  void drawGoalTile(float x, float y) {
    fill(color(20, 20, 80));
    stroke(color(80,80,80));
    rect(tilesToPixels(x), tilesToPixels(y), oneTile, oneTile);
    
    fill(color(80, 80, 80));
    textSize(20);
    text("GOAL", tilesToPixels(x) + eighthTile, tilesToPixels(y) + halfTile);
  }

}


/**
 * The dreaded lava... This paints the entire window with a lava background
 */
public class Lava {
  
  // Each blob is a bubble of lava. We keep 100 of them.
  LavaBlob[] blobs = new LavaBlob[100];
  
  // Set it up with a hundred blobs. There will always be 100 blobs although
  // they will move around to simulate bubbles appearing and bursting
  public Lava() {
    for(int i = 0; i < blobs.length; i++) {
      blobs[i] = new LavaBlob();
    }      
  }
  
  // Function to draw the lava!
  public void draw() {
    
    // First we fill the entire screen in a dark red
    fill(90, 0, 0);
    rect(0, 0, width, height);    
    
    // Then we ask each bubble to draw itself
    for(int i = 0; i < blobs.length; i++) {
      blobs[i].draw();
    }     
  }
  
  // A bubble of lava
  class LavaBlob {    
    // Each lava blob needs to know where it is
    float x = 0;
    float y = 0;
    
    // how big is it?
    float r = 0;
    
    // when did it appear?
    long start;
    
    // Once this bubble has shrunk, "reset" it -- ie turn it into
    // a new bubble randomly placed somewhere else
    public void reset(float w, float h) {
      x = random(w);
      y = random(h);
      r = random(50);
      start = millis();
    }
   
    public void draw() {
      long now = millis() - start;
     
      if (running) { 
        if (r < 1) { 
          // If the radius is < 1, it's time to pop this bubble
          reset(width, height); 
        } else {
          // Otherwise, shrink it slowly. This should cause it to seem
          // like its shrinkage is accelerating slightly
          r = r * (1 - now/20000.0); 
        }
        y += 0.2;
        x += 0.1;
      }
  
      // Draw the bubble
      fill(100, 0, 0);
      stroke(95, 0, 0);
      ellipse(x, y, r, r);      
    }
  }
    
}