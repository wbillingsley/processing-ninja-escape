
int oneTile = 64;
int halfTile = oneTile / 2;
int quarterTile = oneTile / 4;
int eighthTile = oneTile / 8;

PShape ftShape;

void setup() {
  size(1024, 768, P2D);
  orientation(LANDSCAPE);

  ftShape = createShape(RECT, 0, 0, oneTile, oneTile);
  ftShape.setFill(color(60, 60, 60));
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

void draw() {  
    background(204);
    
    for (int y = 0; y < 12; y = y + 1) {
      for (int x = 0; x < 16; x = x + 1) {
        drawFloorTile(x, y);
      }
    }
    drawMonster();
}