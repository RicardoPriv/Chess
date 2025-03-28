# Stock standard piece functions that may be used for any chess piece
class Piece
  attr_accessor :symbol, :color, :collisions, :moves

  def initialize(symbol, color)
    self.symbol = symbol
    self.color = color
    self.collisions = []
    self.moves = []
  end

  def within_board(coordinate)
    return true if (coordinate[0] >= 0 && coordinate[0] < 8) and (coordinate[1] >= 0 && coordinate[1] < 8)

    false
  end

  # Movement for Rook, Bishop and Queen - Adds possible moves for the row/col path and collisions where applicable
  def straight_movement(directions, coordinate, board)
    # Movement for the given directions
    directions.each do |dir_h, dir_v|
      coordinate_copy = coordinate.dup

      # Walks through the path and adds valid tiles
      8.times do
        coordinate_copy[0] += dir_h
        coordinate_copy[1] += dir_v

        # Ends loop if tile is out of bounds or a piece on current tile
        break unless within_board(coordinate_copy) && board[coordinate_copy[0]][coordinate_copy[1]].is_a?(Blank)

        moves.push(coordinate_copy.dup)
      end

      # Adds valid collision tiles to collision variable
      collisions.push(coordinate_copy.dup) if within_board(coordinate_copy)
    end
  end

  # Checks if the movements (coordinate + direction) are valid and adds to moves and collisions where applicable
  # Only works for array of direction eg [[0,1], [1,0]]
  def coordinate_movement(directions, coordinate, board)
    coordinate_copy = []

    # Movement for given directions
    directions.each do |dir_h, dir_v|
      coordinate_copy[0] = coordinate[0] + dir_h
      coordinate_copy[1] = coordinate[1] + dir_v

      # Continues to next iteration if tile is out of bounds
      next unless within_board(coordinate_copy) 

      # Continues to next iteration if collision detected and adds to collisions
      unless board[coordinate_copy[0]][coordinate_copy[1]].is_a?(Blank)
        collisions.push(coordinate_copy.dup)
        next
      end

      moves.push(coordinate_copy.dup)
    end
  end
end
