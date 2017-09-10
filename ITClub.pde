
int oneTile = 64;
int halfTile = oneTile / 2;
int quarterTile = oneTile / 4;
int eighthTile = oneTile / 8;

GameMap gameMap = new GameMap(); 

int numPaths = 4;
int numMonsters = 2;

void setup() {
  size(1024, 768, P2D);
  orientation(LANDSCAPE);
  
  for (int i = 0; i < numPaths; i++) {
    gameMap.makePaths();  
  }
}

PShape calculateMonsterShape() {
    long time = millis();
    float theta = time * 6.3 / 1000;
    
    float blobWidth = (quarterTile + eighthTile) + (eighthTile * sin(theta));
    float blobHeight = (quarterTile + eighthTile) + (eighthTile * cos(theta));
    
    PShape monsterShape = createShape(ELLIPSE, 
      halfTile, halfTile,       // centre in the middle of the tile
      blobWidth,                // our calculated blob width
      blobHeight                // our calculated blob height
    );
    monsterShape.setFill(color(200, 50, 50));
    return monsterShape;    
}

void drawMonster() {
    PShape monsterShape = calculateMonsterShape();
    shape(monsterShape, 0, 0);      
}

float tilesToPixels(float x) {
  return oneTile * x;
}


void draw() {  
    //background(204);
    gameMap.draw();
    drawMonster();
}


public class Action {
  
}


/**
 * We've put the game map into its own "class". This is a way 
 * of grouping variables and functions together.
 */
public class GameMap {
  static final int TilesWide = 16;
  static final int TilesHigh = 12;
  
  static final int NORTH = 0;
  static final int SOUTH = 1;
  static final int EAST = 2;
  static final int WEST = 3;
  
  
  int[][] gameMap = new int[TilesHigh][TilesWide];
  
  // Let's have a nice bubbling lava background
  Lava lava = new Lava();
  
  // We're going to make the paths programmatically -- the map
  // will be different every time!
  public void makePaths() { 
    int x = 0;
    int y = 0;
    
    while (x < TilesWide - 1 || y < TilesHigh - 1) {
      if (y < TilesHigh - 1 && random(2) > 1) {
        int run = (int)random(TilesHigh - y);
        for (int i = 0; i < run; i ++) {
          gameMap[y + i][x] = 1;
        }
        y = y + run;
      } else {
        int run = (int)random(TilesWide - x);
        for (int i = 0; i < run; i ++) {
          gameMap[y][x + i] = 1;
        }
        x = x + run;        
      }
    }
    
    gameMap[y][x] = 1;
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
    return (tx >= 0 && tx < TilesWide && ty >= 0 && ty < TilesHigh && gameMap[ty][tx] != 0); 
  }

  public void draw() {
    lava.draw();
    for (int y = 0; y < TilesHigh; y = y + 1) {
      for (int x = 0; x < TilesWide; x = x + 1) {
        int tileValue = gameMap[y][x];
        switch (tileValue) {
          case 1: 
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
     
      if (r < 1) { 
        // If the radius is < 1, it's time to pop this bubble
        reset(width, height); 
      } else {
        // Otherwise, shrink it slowly. This should cause it to seem
        // like its shrinkage is accelerating slightly
        r = r * (1 - now/20000.0); 
      }
  
      // Draw the bubble
      fill(120, 0, 0);
      stroke(100, 0, 0);
      ellipse(x, y, r, r);
    }
  }
    
}