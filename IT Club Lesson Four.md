class: center, middle

# IT Club Lesson Four

*written hurriedly by Will*

---

class: center, middle

## Monster maze, part One

---

## Monster Maze, part one

We're going to start writing a little game where we have to navigate a maze while avoiding the monsters.

And the monsters are going to be pulsating blobs.

Along the way we're going to learn a few more coding concepts

---

### Setup 

Let's start by setting up the size of the window we want to display

    void setup() {
      size(1024, 768, P2D);
      orientation(LANDSCAPE);
    }

And leave `draw` empty

    void draw() {
    
    }

---

### What, running already?

Click run, and check you get a big empty box.

Programmers try out their code **often**. The less you've changed since you ran it last, the less you have to search through to find what's broken if it didn't work!

---

### Some numbers

Our game is going to be played on a grid of tiles, so the next thing we're going to do is write down a few **constants** -- so we don't forget how big a grid square is.

Right at the top of the file:

    static int oneTile = 64;
    static int halfTile = oneTile / 2;
    static int quarterTile = oneTile / 4;
    static int eighthTile = oneTile / 8;

Now we can't get the numbers wrong

---

### The pulsating blob...

Our Monsters are going to be blobs that pulsate in a disturbing manner...

Let's start by drawing an ellipse.

    void draw() {  
        PShape monsterShape = createShape(ELLIPSE, 
          halfTile, halfTile,       // centre in the middle of the square
          quarterTile + eighthTile, // fat...
          quarterTile - eighthTile  // squat...
        );
        monsterShape.setFill(color(200, 50, 50));
        shape(monsterShape, 0, 0);    
    }

(And run again)

---

### 




