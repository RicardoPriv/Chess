require_relative "../piece.rb"
require_relative "symbols"

# Knight chess piece class
class Knight < Piece
  include Symbols

  def initialize(color)
    super(Symbols::KNIGHT, color)
  end
end
