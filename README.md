<h1 align="center">maze-asm</h1>

<p style="text-align: center;"><em>A project by Flor Ronsmans De Vry for the Computer Systems and Architecture course at the University of Antwerp.</em></p>

<div align="center"><img src="demo/thumbnail.gif"></img></div>

___

## Project description
The goal for this project was to develop a maze game with a customizable layout in assembly which incorporates a pathfinding algorithm for automated solving.

## Goals
- Player movement using memory-mapped I/O
- State display using memory-mapped I/O
- Loading of custom layouts from a file
- Pathfinding algorithm to automatically solve the maze
- Implementation of 'candy' objects, which should be collected before the exit is shown 
- Detect when player finishes level

## Technologies used
- MIPS assembly language
- [MARS (MIPS Assembler and Runtime Simulator)](http://courses.missouristate.edu/kenvollmar/mars/)

## Project overview
- `maze.asm`: final version of the base game
- `maze-auto.asm`: final version of the project including pathfinding algorithm
- `resources/coord-address.asm` program to convert coordinates to memory addresses 
- `resources/red-bitmap.asm` program to show red bitmap through memory-mapped I/O 
- `resources/keyboard-listener.asm` program to listen for memory-mapped input
- `resources/input-parser.asm` program to parse received input
- `read-file.asm` program to read file on host

Misc:
- `resources/demo-base.mp4` Base game demo (including candies/gatekeepers)
- `resources/demo-extension.mp4` Extended game demo (automated)