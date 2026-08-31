# chess

The Odin Project, Project: Chess

## Description:

A Ruby implementation of Chess for The Odin Project Ruby course.

## Features:

### Core Game Play

- Two-player Chess game played from the command line
- 8x8 chess board populated with customisable unicode pieces
- Support for all standard pieces:
  - King
  - Queen
  - Rook
  - Bishop
  - Knight
  - Pawn
- Validation of legal moves for each piece, including special moves such as en passant, castling, and pawn promotion
- Ability to capture pieces, and validation that this is done in line with game-rules
- Detection of Check, Checkmate, and Stalemate
- Ability to save or quit game at any point with ctrl+s or ctrl+q respectively, through use of own get_input methods
- ASCII art and unicode features to enhance UX

### Technical Features

- Considers different attack types: sliding attacks (by Queens, Rooks & Bishops), king attacks, knight attacks, and pawn attacks
- Simulates moves to ensure no move leaves players' own king in check
- Ensures pieces are only selected if they can make a legal move, and once pieces are selected the choice cannot be changed (emulating touch-move rule)
- Considers different possibilities for escaping checkmate: moving king out of check, blocking check with another piece, attacking the checking piece

### Object Oriented Programming

- Separate classes for each piece type
- Player objects responsible for getting player input and checking its validity
- Board object responsible for board state, movement legality, and piece placement
- Game object responsible for introduction to game (including game rules), proceeding through turns, and ending game upon checkmate or stalemate
- Modules such as Check, LegalMoveTo and NextMove to separate and group logic
- Maps to aid checking move legality and reduce space & time complexity

## How it works:

1. Commence programme from Terminal using `ruby play_chess.rb`
2. Select whether you would like to continue a saved game or start a new game
3. Select whether you would like to see the rules of the game
4. Enter player names
   -- Game Play Commences --
5. Enter the coordinate of the piece that you would like to move
6. The game validates that:

- the coordinate contains a piece owned by the current player
- the piece can legally move from the selected coordinate, and without leaving the king in check

7. If the chosen coordinate is invalid, you will be prompted to choose a different coordinate to move from
8. Enter the coordinate you would like to move this piece to
9. The game validates the move, including whether:

- the destination is a valid square
- the piece can legally move to the destination
- the path is clear (where a Queen, Bishop, or Rook are moving)
- the move would leave the king in check

10. If the move is invalid, you will be prompted to choose a different coordinate to move to
11. If the move is valid, the board is updated and the turn passes to the other player
12. The game continues until checkmate or stalemate are reached
    -- Additional Information --

- You will be alerted if you are in check
- You may enter ctrl+s to save the game at any point (once the game has started)
- You may enter ctrl+q to quit the game without saving at any point (once the game has started)

## Concepts practised

This project was built to practise:

- Principles and implementation of variables, input and output, conditional logic, and data types
- Effective use of classes and modules
- Consideration of time and space complexity
- Use of blocks and lambdas
- Testing to ensure effective functioning, support development and aid debugging
- Saving files and serialisation
- Ability to produce DRY code
- Making use of Git

## Future Improvements

- Support variations of chess gameplay e.g. Chess960, 3-check, random starting positions, and handicaps
- Allow players to choose the symbols used
- Introduce an AI computer player
