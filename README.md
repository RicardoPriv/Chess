# Ruby Chess

A fully-functional, object-oriented Chess game built in Ruby. This project was done with the intentio to learn Ruby and to use different concepts in a full project.

---

## Features

- Fully interactive chess game in the terminal
- Object-oriented design with individual classes for each piece
- Move validation with rule enforcement:
  - Castling
  - En passant
  - Pawn promotion
- Check, checkmate, and stalemate detection
- Save and resume games using file-based persistence
- Colored and labeled terminal board
- Threat detection and movement restrictions while in check

---

## Architecture

### Core Classes

| Class        | Responsibility |
|--------------|----------------|
| `Board`      | Manages the game grid, piece positions, threats, legal move validation |
| `Piece` & subclasses | Encapsulates movement rules and state for each chess piece |
| `Mechanics`  | Castling, En paasant and Promotion logic for the board |
| `Game`       | Coordinates the turn flow, player interactions, and win/loss conditions |
| `Helpers`    | Manages coordinate, tile and piece translation |
| `FileManager`| Handles saving and loading game data |

---

## Getting Started

### Prerequisites

- Ruby 3.0 or higher
- Bundler installed (optional, recommended)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/RicardPriv/Chess.git
   cd Chess
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Run the game:
   ```bash
   ruby main.rb
   ```

4. To run tests:
   ```bash
   rspec spec/
   ```

---

## How to Play

- When the game launches, you'll be prompted to start a new game (Type: "new game") or load a saved one. To load a game, enter the exact name of a previously saved file (without extension).
- On your turn, type the coordinates of the piece you wish to move (e.g., `E2`)
- Then type the destination (e.g., `E4`)
- At the destination prompt, you can:
  - Type `b` to go back and reselect the piece
- Possible saving by typing "save" at any prompt (besides promotion) after starting a game
- Includes exit option to exit the program at any point by typing "e"