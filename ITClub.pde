
static int oneTile = 64;
static int halfTile = oneTile / 2;
static int quarterTile = oneTile / 4;
static int eighthTile = oneTile / 8;


void setup() {
  size(1024, 768, P2D);
  orientation(LANDSCAPE);

}

// Drawing is delegated entirely to the game state
void draw() {  
    PShape monsterShape = createShape(ELLIPSE, 
      halfTile, halfTile,       // centre in the middle of the square
      quarterTile + eighthTile, // fat...
      quarterTile - eighthTile  // squat...
    );
    monsterShape.setFill(color(200, 50, 50));
    shape(monsterShape, 0, 0);    
}