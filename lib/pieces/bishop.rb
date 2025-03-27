require_relative "../piece.rb"
require_relative "symbols"

# Bishop chess piece class
class Bishop < Piece
  include Symbols

  def initialize(color)
    super(Symbols::BISHOP, color)
  end
end
