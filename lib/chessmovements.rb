module Chessmovements
  # Checks if the tile is within the borders of a chessboard [A1 - H8]
  def valid_tile?(tile)
    row = tile[0].ord - 65
    col = tile[1].to_i
    return true if (row >= 0 and row < 8) and (col >= 1 and col < 9)
    return false
  end

  # Converts coordinate position on board to chess notation
  def coordinate_to_tile(coordinate)
    return (coordinate[0] + 65).chr + (coordinate[1]).to_s
  end

  # Converts a chess tile (eg A2) into a coordinate (eg 1, 2)
  def tile_to_coordinate(tile)
    return [tile[0].ord - 65, tile[1].to_i]
  end

  # checks at the given position on the board if there is a piece of the opposing player (opponent of given player)
  def opponent_piece?(coordinate, player, board)
    return false unless valid_tile?(coordinate_to_tile([coordinate[1], coordinate[0]]))

    row = board[coordinate[0]]
    cell = row[coordinate[1]]

    return false if cell[:color].nil?
    return true if cell[:color] != player && !cell[:color].nil?
  end

  # Returns possible pawn movements
  def pawn_moves(tile, board, player)
    for_direction = player == :white ? 1 : -1
    possible_moves = Array.new
    coordinate = tile_to_coordinate(tile)

    # Movement for single forward and diagonals if there is a capture target
    (0..2).each do |i|
      move = coordinate.dup.tap { |j| j[0], j[1] = j[0] - 1 + i, j[1] + for_direction }
      next if i % 2 == 0 && !opponent_piece?(move, player, board)
      possible_moves.push(move) if valid_tile?(coordinate_to_tile(move))
    end

    # Movement for double starting jump and sets the direction depending on player colour
    if (player == :white && coordinate[1] == 2) || (player == :black && coordinate[1] == 7)
      possible_moves.push(coordinate.dup.tap { |i| i[1] = i[1] + (2 * for_direction) })
    end

    possible_moves.each_with_index { |i, index| possible_moves[index] = coordinate_to_tile(i) }

    return possible_moves
  end

  # Vertical and Horixontal movement of the rook piece
  def rook_moves(tile, board, player)
    directions = [[1, 0], [-1, 0], [0, 1], [0, -1]]
    return straight_movement(directions, tile, board, player)
  end

  def knight_moves(tile, board, player)
    directions = [[2, 1], [-2, 1], [2, -1], [-2, -1], [1, 2], [-1, 2], [1, -2], [-1, -2]]
    return coordinate_movement(directions, tile, board, player)
  end

  # Diagonal movement of the bishop piece
  def bishop_moves(tile, board, player)
    directions = [[1, 1], [1, -1], [-1, -1], [-1, 1]]
    return straight_movement(directions, tile, board, player)
  end

  def queen_moves(tile, board, player)
    directions = [[1, 0], [-1, 0], [0, 1], [0, -1], [1, 1], [1, -1], [-1, -1], [-1, 1]]
    return straight_movement(directions, tile, board, player)
  end

  # Movement for King / positions surrounding current tile
  def king_moves(tile, board, player)
    directions = [[1, 0], [-1, 0], [0, 1], [0, -1], [1, 1], [1, -1], [-1, -1], [-1, 1]]
    return coordinate_movement(directions, tile, board, player)
  end

  # Converts and array of coordinates to their Chess tiles
  def array_coordinates_to_tiles(coordinates)
    tiles = Array.new
    coordinates.each do |i|
      tiles.push(coordinate_to_tile(i).dup)
    end
    return tiles
  end

  def straight_movement(directions, tile, board, player)
    possible_moves = Array.new

    # Movement for the given directions
    directions.each do |dir|
      coordinate = tile_to_coordinate(tile)

      # Walks through the path and adds valid tiles
      8.times do
        coordinate[0] += dir[0]
        coordinate[1] += dir[1]
        # Ends loop if tile is out of bounds
        break unless valid_tile?(coordinate_to_tile(coordinate))

        # Ends loop if there is a piece on the current tile and adds if it is the opponents piece
        unless board[coordinate[1] - 1][coordinate[0]][:type] == :empty
          possible_moves.push(coordinate.dup) if opponent_piece?([coordinate[1] - 1, coordinate[0]], player, board)
          break
        end

        possible_moves.push(coordinate.dup)
      end
    end

    # Converts piece coordinates back to Chess standard tiles
    return array_coordinates_to_tiles(possible_moves)
  end

  # Given x coordinates, checks if the movements (tile + coordinate) are valid and returns valid movements
  def coordinate_movement(directions, tile, board, player)
    possible_moves = Array.new

    directions.each do |dir|
      coordinate = tile_to_coordinate(tile)
      coordinate[0] += dir[0]
      coordinate[1] += dir[1]

      # Continues to next iteration if tile is out of bounds
      next unless valid_tile?(coordinate_to_tile(coordinate))

      # Continues to next iteration if there is a piece on the current tile and adds if it is the opponents piece
      unless board[coordinate[1] - 1][coordinate[0]][:type] == :empty
        possible_moves.push(coordinate.dup) if opponent_piece?([coordinate[1] - 1, coordinate[0]], player, board)
        next
      end

      possible_moves.push(coordinate.dup)
    end

    return array_coordinates_to_tiles(possible_moves)
  end
end
