# Technical document

This document contains the information you might require if you wish to run the game or expand on it.

## How to run this project

### 1. The source version

The source version of this game is a Godot project with the addition of a database and a statistics web page. To run it on your machine:
1. Install Godot. Version 4.3 is required
2. Install Node.js
3. Open the main folder ("Fisheries game") as a Godot project
4. Open the folder "backend" in terminal
5. Install the dependencies by running "npm install"
6. Start the backend server by running "node server.js"
7. Finally, run the project in Godot!

You will be able to play the game in the editor and open the statistics page in your browser.

### 2. Web export

If you want to export the game to the web, after making sure you cn run the source version, you should follow this instruction:
1. In Godot, find the "Project" option in the topmost navigation bar
2. Select "Export..." in the drop-down menu
3. An Export window will appear. On top of the empty list of presets, click "Add.." and select the one for the Web
4. A warning about the lack of export templates will appear. Click on "Manage Export Templates"
5. In the window that appears, click on "Download and Install" and wait for the templates to install. It may take around 10 minutes
6. When the installation is done, return to the Export window
7. In the export options, make sure that "Thread Support" is OFF and "Ensure Cross Origin Isolation Headers" is ON
8. Click on "Export Project...", create a destination folder, and click "Export"
9. Done! You have successfully exported the Godot project.

### 3. Running the exported version 

To run the exported version on your local machine, do the following:

1. Perform steps 4-6 from the source version tutorial to run the backend server
2. In the folder with your exported files, run a local http server (for example, with "http-server -p your_port")
3. Open localhost:your_port and play!

## File and database descriptions

### Files and folders

- The main folder contains a bunch of .gd and .tscn files. These are Godot scripts and scenes correspondingly, which are extensively documented inside
- The "addons" folder contains the only Godot add-on used in this project: Graph2D. It has been modified to better fit the needs of the project
- The "art" folder contains the sprites
- The "database" folder contains the database and database server
- The "public" folder contains the statistics web page

### Database

The database stores the following data about each player that has successfully finished the game:

- ID: integer, unique for each player
- username: text
- objective: text, "Capture" / "Profit"
- total_capture: real number
- total_profit: real number
- capture: text; an array of exactly 60 real numbers turned into string, marking current capture at all 1-second marks
- profit: text; an array of exactly 60 real numbers turned into string, marking current profit at all 1-second marks
- fish_population: text; an array of exactly 60 real numbers turned into string, marking current fish population at all 1-second marks
- ships: text; an array of exactly 60 integer numbers turned into string, marking current number of ships at all 1-second marks
- timestamp: datetime
