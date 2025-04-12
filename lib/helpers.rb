# Helper functions for conversions
module Helpers
  # takes the tile (eg: A1) and retrieves the piece hash at that position on the board
  def tile_to_piece(tile)
    row = board[tile[1].to_i - 1]
    row[tile[0].ord % 65]
  end

  # Converts coordinate position on board to chess notation
  def coordinate_to_tile(coordinate)
    (coordinate[1] + 65).chr + (coordinate[0] + 1).to_s
  end

  # Converts a chess tile (eg A2) into a coordinate (eg 1, 0) [row, col]
  def tile_to_coordinate(tile)
    [tile[1].to_i - 1, tile[0].ord - 65]
  end

  # Converts and array of coordinates to their Chess tiles
  def array_coordinates_to_tiles(coordinates)
    coordinates.map { |i| coordinate_to_tile(i).dup }
  end

  # Checks if the tile is within the borders of a chessboard [A1 - H8]
  def within_borders?(tile)
    row = tile[0].ord - 65
    col = tile[1].to_i
    return true if (row >= 0 && row < 8) && (col >= 1 && col < 9)

    false
  end

  # checks at the given position on the board if there is a piece of the opposing player (opponent of given player)
  def opponent_piece?(coordinate, player)
    return false unless within_borders?(coordinate_to_tile([coordinate[0], coordinate[1]]))

    row = board[coordinate[0]]
    cell = row[coordinate[1]]

    return true if cell.color != player && !cell.is_a?(Blank)

    false
  end

  def piece_from_tile(tile)
    coordinate = tile_to_coordinate(tile)
    board[coordinate[0]][coordinate[1]]
  end

  # Retrieves the coordinates between two given coordinates
  def coords_between(start_coord, end_coord)
    line = []
    r1, c1 = start_coord
    r2, c2 = end_coord
    dr = r2 <=> r1
    dc = c2 <=> c1

    cur_r = r1 + dr
    cur_c = c1 + dc

    while [cur_r, cur_c] != [r2, c2]
      line << [cur_r, cur_c]
      cur_r += dr
      cur_c += dc
    end

    line
  end
end
