
int oneTile = 64;
int halfTile = oneTile / 2;
int quarterTile = oneTile / 4;
int eighthTile = oneTile / 8;

boolean running = true;
int numPaths = 4;
int numMonsters = 2;
GameMap gameMap = new GameMap(); 
BlobMonster[] monsters = new BlobMonster[0]; 

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
  setupMonsters();
}



float tilesToPixels(float x) {
  return oneTile * x;
}


void draw() {  
    //background(204);
    gameMap.draw();
    for (BlobMonster m : monsters) { 
      m.draw();
    }
}


public class Move {
  static final int IDLE = 0;
  
  long start;
  long direction;
  
  public Move(int dir) {
    this.direction = dir;
    this.start = millis();
  }
  
}


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
  
  void draw() {
    long time = millis();
    float theta = time * 6.3 / 1000;
    
    if (running) {
      blobWidth = (quarterTile + eighthTile) + (eighthTile * sin(theta));
      blobHeight = (quarterTile + eighthTile) + (eighthTile * cos(theta));
    }

    fill(200, 50, 50);
    stroke(200, 70, 70);
    ellipse(tilesToPixels(x) + halfTile, tilesToPixels(y) + halfTile, blobWidth, blobHeight);
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
    gameMap[TilesHigh - 1][TilesWide - 1] = FLOOR;
    gameMap[TilesHigh - 2][TilesWide - 1] = FLOOR;
    gameMap[TilesHigh - 1][TilesWide - 2] = FLOOR;
    gameMap[TilesHigh - 2][TilesWide - 2] = FLOOR;
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
          
        }
      }
    } 
  }
  
  void drawFloorTile(float x, float y) {
    fill(color(20, 20, 20));
    stroke(color(80,80,80));
    rect(tilesToPixels(x), tilesToPixels(y), oneTile, oneTile);
  }
}


/**
 * The dreaded lava... This paints the entire window with a lava background
 */
public class Lava {
  
  // Each blob is a bubble of lava
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
      }
  
      // Draw the bubble
      fill(120, 0, 0);
      stroke(100, 0, 0);
      ellipse(x, y, r, r);
    }
  }
    
}