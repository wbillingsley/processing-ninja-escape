
int oneTile = 64;
int halfTile = oneTile / 2;
int quarterTile = oneTile / 4;
int eighthTile = oneTile / 8;

PShape ftShape;
PShape wtShape;

Lava lava = new Lava();

int[][] gameMap = {
    { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    { 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1 },
    { 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1 },
    { 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 1 },
    { 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
    { 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1 },
    { 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1 },
    { 1, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1 },
    { 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1 },
    { 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1 },
    { 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1 },
    { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }
};

void setup() {
  size(1024, 768, P2D);
  orientation(LANDSCAPE);

  ftShape = createShape(RECT, 0, 0, oneTile, oneTile);
  ftShape.setFill(color(60, 60, 60));
  
  wtShape = createShape(RECT, 0, 0, oneTile, oneTile);
  wtShape.setFill(color(100, 100, 80));  
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

void drawFloorTile(float x, float y) {
  shape(ftShape, tilesToPixels(x), tilesToPixels(y));
}

void drawWallTile(float x, float y) {
  shape(wtShape, tilesToPixels(x), tilesToPixels(y));
}

void draw() {  
    //background(204);
    lava.draw();
    for (int y = 0; y < 12; y = y + 1) {
      for (int x = 0; x < 16; x = x + 1) {
        int tileValue = gameMap[y][x];
        if (tileValue == 0) {
          drawFloorTile(x, y);
        } else if (tileValue == 1) {
          //drawWallTile(x, y);
        }
      }
    }
    drawMonster();
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
    fill(75, 0, 0);
    rect(0, 0, width, height);    
    
    // Then we ask each bubble to draw itself
    for(int i = 0; i < blobs.length; i++) {
      blobs[i].draw();
    }     
  }
  
  // A bubble of lava
  class LavaBlob {    
    // where is it?
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
  
      
      fill(100, 0, 0);
      stroke(120, 0, 0);
      ellipse(x, y, r, r);
    }
  }
    
}