require_relative "chessboard"

module Gameloop
  def play
    gameboard = Chessboard.new
    gameboard.print_board
  end
end
