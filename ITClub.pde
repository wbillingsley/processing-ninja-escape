
/**
 * A variable to hold our game state
 */
GameState gs; 

void setup() {
  size(1024, 768, P2D);
  orientation(LANDSCAPE);

  gs = new GameState();  
}

// Drawing is delegated entirely to the game state
void draw() {
  gs.draw();  
}