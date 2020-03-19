
Your task is to create a mine-sweeper style game.
You start at the bottom of an 8x8 grid with 5 lives.
You must move to the top whilst trying to avoid the hidden mines.
You move up/down/left/right each turn.
If you step on a mine:
  o) the mine is revealed and shown as '*'
  o) you lose a life
  o) you do not move into the mine's square
  o) the mine remains explosive
Your current position is shown as 'O'
Squares you have previously stepped on are shown as 'o'
If you reach the top of the grid you win and the game ends.
If you run out of lives you lose and the game ends.
If you attempt to move off the grid:
  o) you stay in the same square
  o) you do not lose a life
A parameter holds the likelihood each square contains a mine:
  o) this parameter ranges from 0 (inclusive) to 1 (exclusive)
  o) a value of 0 means no square contains a mine
  o) a value of 0.5 means a 50% chance any square is mined
  o) reject generated grids with no mine-free path to the top
  o) in other words, each game must be winnable
Your initial starting position at the bottom:
  o) is randomly chosen
  o) does not contain a mine
