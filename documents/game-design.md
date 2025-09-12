# Game Design Document - echo of me


A game design document is living document which describes the intent of the game design. 
It has two goals, first to document the decisions that have been made about the game and communicate those concepts to the entire team. 
Thus, it needs to be detailed enough for programmers to refer to when they need clarification about an aspect of the game. 
It must be able to be updated as the game is to be built. 
The need to have a game design document increases with the size of the team and length of the project. 

For a student project the intent is to capture as much as possible of your design. 
The game design will be larger than what you can achieve in a semester, but you must then decide what you need to do first. 
This document should be in version control so that you can see it changing and growing. 
Given we are using git you could also use @name to assign parts of the design to individual members of the team.


## Overview
*Echo of me* , 
*Magnus Dybdal & Marius Eilertsen*

### Game Concept
What the game is about?


### Genre
What other games is it like?
The game is a 2D puzzle platformer.
Other similar games are:
- Celeste
- Trine-series

### Target Audience
Who will play it?
Enjoyers of a casual 2D platformer. In terms of difficulty it should be challenging, but this depends entierly on the previous knowledge and skill of the players.  

### Game Flow Summary
How does the player move through the game?
- The map doesn't move (no camera movement), and you should be able to see the whole level in one "viewport".
- Player play with WASD or arrows.
- The player completes the level/platform in order to move on to the next one. (Think super mario)

### Look and Feel
What is the basic look and feel of the game?  What is the visual style?
- Simple pixelart, Celeste is a good reference here. 
- We want to incorporate a different visual style than "outdors and a bright sunny day", a bit more on the "moody" side - TBD.

## Gameplay and Mechanics
You record your actions for a short window, then spawn a translucent “Echo” that replays them exactly.
Working alongside your Echo, you coordinate timing to hold plates, open timed doors, ride moving platforms, and block hazards so the live player can reach the exit.

### Gameplay
The core interaction is your interaction with your own echo, and their ineraction with the objects in the world.

#### Game progression
The player progresses through the levels. The player will be reminded which level they are through some use of HUD. The player will experience new abilities and ways to use the echo in order to complete the puzzels. 

#### Mission/challenge Structure
The hierachy of the games challenges is linear, through the completion of the puzzels. 

#### Puzzle Structure
All puzzles have a correct answer, there might however be multiple ways of completing each puzzle.

#### Objectives
There main objective is to complete teh puzzle. We will incorporate a story-arch that motivates the player with a story-like experience, aside from the puzzles themselves.


### Mechanics
What are the rules to the game, both implicit and explicit?  
This is the model of the universe that the game works under.  
Think of it as a simulation of a world. How do all the pieces interact?

#### Physics
How does the physical universe work?
The world physics are not made to be realistic, but simulated to feel good and "snappy". Gravity will affect objects and the players differently depending on their properties. 

#### Movement
How the player interacts with the game?
The player runs around and jumps when needed. The core mechanics of the player is quite simple.

#### Objects
What are the objects in the game?
How does the player interact with them?
- boxes
- buttons/pressure plates
- platforms
- doors
- lasers

#### Actions
What are the other interactions the player has with the game world?
- move boxes
- jump on top of boxes
- push/trigger buttons/pressure plates
- jump on platforms
- open doors
- reflect/redirect lasers

#### Combat
There are no plans for combat yet.

#### Economy
What is the economy of the game? How does it work?
The economy of the game is static. Throughout the games progression the player will obtain additional mechanics that can be utilized to complete further puzzles.

#### Screne Flow
A graphical description of how each screen is related to every other and a description of the purpose of each screen.
- Main menu
    - Play- / Continue
    - Load- / Save game
    - Level selector
    - Settings
    - Exit game
- Gameplay
    - Pause screen


### Game Options
What are the options and how do they affect gameplay and mechanics?
There will be no options. The game is set of us. Git gud.

### Replay and Saving
Game progress will be saved in a file that can be loaded and saved. 
The levels should be able be replayed. They will stay the same. 

### Cheats and Easter Eggs
We don't condone cheats.
There are no plans for easter eggs yet, but we will not leave this out.

## The Story, Setting, and Character


### Story and Narrative
If there is a story component includes back story, plot elements, game progression, and cut scenes. 
Cut scenes descriptions include the actors, the setting, and the storyboard or script.

- As of right now, there are no storyline, though we want to incorporate some story-elements over time.

### Game World
The setting of the game
The world is set in a cave you enter to find out more about your ancestors. The whole game is set in this cave.

#### General look and feel of the World
Aesthetics
- Dark and moody caves, but not "limbo"-dark. Single light sources like torches. 
This all depends on the assets we are able to find. 

#### Areas
including the general description and physical characteristics as well as how it relates to the rest of the world 
(what levels use it, how it connects to other areas).
- Cave

### Characters
Each character should include the back story, personality, appearance, animations, abilities, relevance to the story and relationship to other characters.
- The main character is named by the user at the begining of each save. 
- All else is TBD.
- Relations to the Echos is that the echos is the ancestors of the main character. The player will learn this along the way. 

## Levels

### Playing Levels
Each level should include a synopsis, the required introductory material (and how it is provided), the objectives, 
and the details of what happens in the level.  
Depending on the game, this may include the physical description of the map, the critical path that the player needs to take, 
and what encounters are important or incidental.

### Training level
How is onboarding managed?
Every new level that introduces a new "ability" will have to be easy in order to have focus on the abilitys usage. 
This can also include a hint-textbox that explains how the core mechanics of the ability work.

## Interface

### Visual System
If you have a HUD, what is on it?  What menus are you displaying? What is the camera model?
- There is no hud when the gameplay is running. 

### Control System
How does the game player control the game?   What are the specific commands?
- WASD
- Arrow keys
- SPACE to jump
- R reset game
- E Spawn echo

### Audio, Music, Sound Effects
TBD
If we find licence free assets we will prefer to use this.

### Help System
- Hint-textboxes

## Artificial Intelligence

### Opponent and Enemy AI
The active opponent that plays against the player and therefore requires strategic decision making.
- No enemies

### Non-combat and Friendly Characters
- Echos - core mechanic
- We wish to implement story-characters that will help the player get a feeling of progress, and they will be able to provide hints and context to the story. 
### Support AI
TBD - not relevant?
### Player and Collision Detection, Path-finding.
TBD
## Technical

### Target Hardware
- The game should be able to run on most machines with internal graphics.

### Development Hardware and Software (including game engine)
- Software: Godot
- We develop on our personal machinces:
    - Lenovo Legion 5
    - Macbook Pro 16 M1

### Network requirements
No network required for playing this game.

## Game Art

### Key assets 
How are they being developed.  Intended style.
- TBD.

This is an extension of parts of [cs.unc.edu](http://wwwx.cs.unc.edu/Courses/comp585-s11/585GameDesignDocumentTemplate.docx)

