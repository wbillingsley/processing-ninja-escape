# IT Club Lesson Four


*written hurriedly by Will*

## Activity 2.1 Monster Maze, part one

When programs get large, we need to break them up into chunks. That's not for the computer's benefit -- it could cope with a huge long list of code -- it's for our benefit so we can remember where to look for parts of the code as we edit them.

We're going to start writing a little game where we have to navigate a maze while avoiding the monsters.

And the monsters are going to be pulsating blobs.


### Setup 

Let's start by setting up the size of the window we want to display

    void setup() {
      size(1024, 768, P2D);
      orientation(LANDSCAPE);
    }


To animate our maze, we're going to need to work out what it looks like at every tick -- where the monsters are, where we are. This is going to get a bit big, so we're going to create **classes** and **objects** to hold different parts.

A **class** describes what an object should be like -- dogs have a name, for instance. And then we can tell the computer we would like 