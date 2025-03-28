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
    directions.each do |dir|
      coordinate_copy = coordinate.dup

      # Walks through the path and adds valid tiles
      8.times do
        coordinate_copy[1] += dir[1]
        coordinate_copy[0] += dir[0]

        # Ends loop if tile is out of bounds or a piece on current tile
        break unless within_board(coordinate_copy) && board[coordinate_copy[0]][coordinate_copy[1]].is_a?(Blank)

        moves.push(coordinate_copy.dup)
      end

      # Adds valid collision tiles to collision variable
      collisions.push(coordinate_copy.dup) if within_board(coordinate_copy)
    end
  end

  # Given x coordinates, checks if the movements (tile + coordinate) are valid and returns valid movements
  def coordinate_movement(directions, tile, board, player)
    possible_moves = Array.new

    directions.each do |dir|
      coordinate = tile_to_coordinate(tile)
      coordinate[0] += dir[0]
      coordinate[1] += dir[1]

      # Continues to next iteration if tile is out of bounds
      #next unless valid_tile?(coordinate_to_tile(coordinate))

      # Continues to next iteration if there is a piece on the current tile and adds if it is the opponents piece
      unless board[coordinate[0]][coordinate[1]][:type] == :empty
        possible_moves.push(coordinate.dup) if opponent_piece?([coordinate[0], coordinate[1]], player, board)
        next
      end

      possible_moves.push(coordinate.dup)
    end

    possible_moves
  end
end
