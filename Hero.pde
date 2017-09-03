
interface HeroAction {
 
  void draw(Hero h);
  
  void onComplete(Hero h);
  
  boolean isFinished();  
  
}

/**
 * The action for when our Monster is not doing anything
 */
class HeroIdle implements HeroAction {
  
  void draw(Hero h) {
    PShape myShape = h.calcShape(h.facing * PI/2);
    shape(myShape, h.x * Tile.spriteHeight, h.y * Tile.spriteHeight);
  }
  
  void onComplete(Hero h) {
    // Nothing, we're idle 
  }
  
  boolean isFinished() {
    return true; 
  }
  
}

/**
 * The action for when our Monster is not doing anything
 */
class HeroTurning implements HeroAction {
  
  boolean clockwise;
  
  long whenBegan = millis();
  float duration = 500.0;
   
  public HeroTurning(boolean clockwise) {
    this.clockwise = clockwise; 
  }
  
  void draw(Hero h) {
    
    long elapsed = millis() - whenBegan;
    float angle = (elapsed / duration) * PI/2;
    
    PShape myShape;
    if (clockwise) {
      myShape = h.calcShape(angle + h.facing * (PI/2));
    } else {
      myShape = h.calcShape(-angle + h.facing * (PI/2));
    }    
    shape(myShape, h.x * Tile.spriteHeight, h.y * Tile.spriteHeight);
  }
  
  void onComplete(Hero h) {
    if (clockwise) {
      h.facing = (h.facing + 5) % 4;
    } else {
      h.facing = (h.facing + 3) % 4;
    }
  }
  
  boolean isFinished() {
    return (millis() - whenBegan) > duration; 
  }
  
}

class HeroMoving implements HeroAction {
  
  float duration = 500.0;
  long whenBegan;
  int direction;
  
  HeroMoving(int direction) {
    whenBegan = millis();
    this.direction = direction;
  }
  
  void draw(Hero m) {
    PShape myShape = m.calcShape(m.facing * PI/2);
    
    long elapsed = millis() - whenBegan;
    float frac = elapsed / duration;
    
    int offsetX, offsetY;
    switch(direction % 4) {
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
  
  void onComplete(Hero m) {
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

class Hero {
  
  int x, y, facing;
  HeroAction action;
  
  Hero(int x, int y, int facing) {
    this.x = x;
    this.y = y;
    this.facing = facing;
    
    this.action = new HeroIdle();
  }
  
  
  /**
   * The shape of our Hero is a triangle, facing at a particular angle
   */
  PShape calcShape(float angle) {    
    int half = Tile.spriteHeight / 2;
    int quarter = half / 2;
    int eighth = quarter / 2;
    PShape shape = createShape(TRIANGLE, 
      -quarter, quarter,
      quarter, quarter,
      0, -quarter
      //quarter, 3 * quarter,
      //3 * quarter, 3 * quarter,
      //half, quarter
    );
    shape.rotate(angle);
    shape.translate(half, half);
    shape.setFill(color(50, 200, 50));
    return shape;
  }
  
  
  void draw(GameState gs) {
    if (action.isFinished()) {
      action.onComplete(this);
      this.action = new HeroIdle();
      if (keyPressed) {
        if (key == 'a') {
          this.action = new HeroTurning(false);
        } else if (key == 'd') {
          this.action = new HeroTurning(true);
        } else if (key == 'w' && gs.canMove(x, y, facing)) {
          this.action = new HeroMoving(this.facing);
        }
      }
    }
    action.draw(this);    
  }
  
  
}