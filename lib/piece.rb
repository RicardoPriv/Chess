# Stock standard piece functions that may be used for any chess piece
class Piece
  attr_accessor :symbol, :color

  @moves = nil
  @collisions = nil

  def initialize(symbol, color)
    self.symbol = symbol
    self.color = color
  end
end
