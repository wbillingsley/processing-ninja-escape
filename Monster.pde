interface MonsterAction {
  
  void draw(Monster m);
  
  void onComplete(Monster m);
  
  boolean isFinished();
  
}

/**
 * The action for when our Monster is not doing anything
 */
class MonsterIdle implements MonsterAction {
  
  void draw(Monster m) {
    PShape myShape = m.calcShape(millis());
    myShape.setFill(color(200, 50, 50));
    shape(myShape, m.x * Tile.spriteHeight, m.y * Tile.spriteHeight);
  }
  
  void onComplete(Monster m) {
    // Nothing, we're idle 
  }
  
  boolean isFinished() {
    return true; 
  }
  
}

/*
 * The action for when our Monster is moving one square N, S, E, W
 * 0 = North, 1 = East, 2 = South, 3 = West
 */
class MonsterMoving implements MonsterAction {
  
  long duration = 1000;
  long whenBegan;
  int direction;
  
  MonsterMoving(int direction) {
    whenBegan = millis();
    this.direction = direction;
  }
  
  void draw(Monster m) {
    PShape myShape = m.calcShape(millis());
    myShape.setFill(color(200, 50, 50));
    
    long elapsed = millis() - whenBegan;
    float frac = elapsed / 1000.0;
    
    int offsetX, offsetY;
    switch(direction) {
      case 0:
        offsetX = 0;
        offsetY = -(int)(frac * Tile.spriteHeight);
        break;  
      case 1:
        offsetX = (int)(frac * Tile.spriteHeight);
        offsetY = 0;
        break;
      case 2: 
        offsetX = 0;
        offsetY = (int)(frac * Tile.spriteHeight);
        break;  
      case 3:
        offsetX = -(int)(frac * Tile.spriteHeight);
        offsetY = 0;
        break;  
      default:
        throw new IllegalStateException("Somehow we have a direction that is not n, s, e, or w");
    }
    
    shape(myShape, offsetX + m.x * Tile.spriteHeight, offsetY + m.y * Tile.spriteHeight);
  }
  
  void onComplete(Monster m) {
    // Update the monster's x and y location
    switch(direction) {
      case 0:
        m.y -= 1;
        break;  
      case 1:
        m.x += 1;
        break;
      case 2: 
        m.y += 1;
        break;  
      case 3:
        m.x -= 1;
        break;  
      default:
        throw new IllegalStateException("Somehow we have a direction that is not n, s, e, or w");
    }
  }
  
  boolean isFinished() {
    return millis() - whenBegan > duration; 
  } 
  
}

/**
 *  How our monster decides what action to do next
 */ 
interface MonsterStrategy {
  MonsterAction nextAction(GameState gs, Monster m);  
}

class MonsterPatrolling implements MonsterStrategy {
  
  /**
   *  Chooses a random direction to move in 
   */ 
  MonsterAction randomMove(GameState gs, Monster m) { 
    ArrayList<Integer> directions = new ArrayList<Integer>();
    for (int i = 0; i < 4; i++) {
      if (canMove(gs, m, i)) {
        directions.add(i);
      }
    }
    if (directions.size() > 0) {
      return new MonsterMoving(directions.get((int)random(directions.size())));  
    } else {
      // We can't move in any direction, so just idle.
      return new MonsterIdle();
    }
  }
  
  /**
   * Chooses a next action for our monster
   */
  MonsterAction nextAction(GameState gs, Monster m) {
    if (canContinue(gs, m)) {
      MonsterMoving lastMove = (MonsterMoving)m.action;
      return new MonsterMoving(lastMove.direction);  
    } else {
      // See which moves are available, and pick a random one
      return randomMove(gs, m);
    }      
  }
  
  /**
   * returns true if we can move in a particular direction
   */ 
  boolean canMove(GameState state, Monster m, int direction) {
    int nextX, nextY;
      switch(direction) {
        case 0:
          nextX = m.x;
          nextY = m.y - 1;
          break;  
        case 1:
          nextX = m.x + 1;
          nextY = m.y;
          break;
        case 2: 
          nextX = m.x;
          nextY = m.y + 1;
          break;  
        case 3:
          nextX = m.x - 1;
          nextY = m.y;
          break;  
        default:
          throw new IllegalStateException("Somehow we have a direction that is not n, s, e, or w");
      }
      
      return state.isPassable(nextX, nextY);   
  }
  
  
  /**
   * returns true if our current action was a move, and we can continue in that direction
   */
  boolean canContinue(GameState state, Monster m) {
    if(m.action instanceof MonsterMoving) {
      MonsterMoving lastMove = (MonsterMoving)m.action;
      return canMove(state, m, lastMove.direction);
    } else return false;
  }  
  
}

/**
 * The dreadful pulsating ellipse monster...
 */
class Monster {
  int x, y;
  
  MonsterAction action;
  
  MonsterStrategy strategy;
  
  long animDuration = 1000; 
  
  /**
   * The shape of our monster is a red ellipse, that pulses menacingly
   */
  PShape calcShape(long millis) {
    long framePoint = millis % animDuration; // % is the "mod" operator
    float angle = ((TWO_PI * framePoint) / animDuration);
    int half = Tile.spriteHeight / 2;
    int quarter = half / 2;
    int eighth = quarter / 2;
    PShape shape = createShape(ELLIPSE, 
      half, half, // still centered in the middle of the square
      quarter + eighth + eighth * sin(angle), // fatness changes with sin
      quarter + eighth + eighth * cos(angle)  // tallness changes with cos
    );
    shape.setFill(color(200, 50, 50));
    return shape;
  }
  
  /**
   * This is the "constructor" for our monster. It is called when you call "new Monster(3, 4)"
   */ 
  Monster(int x, int y) {
    this.x = x;
    this.y = y;
    
    this.action = new MonsterMoving(1);
    this.strategy = new MonsterPatrolling();
  }
 
  /**
   * Called by the game state to render our Monster.
   * First it processes any changes to the monster's action that are necessary.
   * Then it delegates the drawing to the monster's current action.
   */
  void draw(GameState state) {
    if (action.isFinished()) {
      action.onComplete(this);
      this.action = strategy.nextAction(state, this);
      
    }
    action.draw(this);
  }
  
}