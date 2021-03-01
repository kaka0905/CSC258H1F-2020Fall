# CSC258H1F-2020Fall
My work in CSC258(Computer Organization)
# Final project: Doodle jump
# Project description: 
In this project, we will implement the Doodle jump game using Assembly language
5 milestones in total
# Project information:
Bitmap Display Configuration:
- Unit width in pixels: 8
- Unit height in pixels: 8
- Display width in pixels: 256
- Display height in pixels: 256
- Base Address for Display: 0x10008000 ($gp)

Milestone reached in this submission: Milestone 4
Features in Milestone4:
i. Game Over and retry(retry is not printed on the screen,
   there will be an instruction below).
ii. Scoreboard will be displayed in the game over screen.

Instruction:
1. Press 's' to start, the screen will generate plates and the doodle
2. Press 'j' to make doodle move to left
3. Press 'k' to make doodle move to right
4. When the doodle die, the score of the player will be displayed
   under "GAME OVER", note that the initial board will not be counted
   into the overall score. If the doodle fall from current board,
   that board will not be counted as well.
5. Press 's' to get back to the start screen. 
   Press 'e' to quit.
   Press 's' again to re-start.**
