require_relative "../piece.rb"
require_relative "symbols"

# Queen chess piece class
class Queen < Piece
  include Symbols

  def initialize(color)
    super(Symbols::QUEEN, color)
  end
end
