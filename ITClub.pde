
int oneTile = 64;
int halfTile = oneTile / 2;
int quarterTile = oneTile / 4;
int eighthTile = oneTile / 8;


void setup() {
  size(1024, 768, P2D);
  orientation(LANDSCAPE);

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

void draw() {  
    background(204);
    PShape monsterShape = calculateMonsterShape();
    shape(monsterShape, 0, 0);    
}