# frozen_string_literal: true

require_relative '../lib/board'
require_relative '../lib/mechanics'

class MechanicsTester
  include Mechanics
  include Helpers
  attr_accessor :board

  def initialize(board)
    @board = board
  end
end

describe Mechanics do
  let(:board_instance) { MechanicsTester.new(Array.new(8) { Array.new(8) { Blank.new } }) }

  describe '#promotion' do
    it 'returns the tile of a pawn ready for promotion for white' do
      board_instance.board[7][0] = Pawn.new(:white)
      expect(board_instance.promotion(:white, board_instance.board)).to eq('A8')
    end

    it 'returns the tile of a pawn ready for promotion for black' do
      board_instance.board[0][7] = Pawn.new(:black)
      expect(board_instance.promotion(:black, board_instance.board)).to eq('H1')
    end

    it 'returns an empty string if no promotion is possible' do
      expect(board_instance.promotion(:white, board_instance.board)).to eq('')
    end
  end

  describe '#king_castle' do
    it 'moves the rook during kingside castling for white' do
      king = King.new(:white)
      rook = Rook.new(:white)
      board_instance.board[0][4] = king
      board_instance.board[0][7] = rook

      board_instance.king_castle(king, 'G1', board_instance.board)

      expect(board_instance.board[0][5]).to be_a(Rook)
      expect(board_instance.board[0][7]).to be_a(Blank)
    end

    it 'moves the rook during queenside castling for black' do
      king = King.new(:black)
      rook = Rook.new(:black)
      board_instance.board[7][4] = king
      board_instance.board[7][0] = rook

      board_instance.king_castle(king, 'C8', board_instance.board)

      expect(board_instance.board[7][3]).to be_a(Rook)
      expect(board_instance.board[7][0]).to be_a(Blank)
    end

    it 'does nothing if piece is not eligible for castling' do
      piece = Knight.new(:white)
      board_instance.king_castle(piece, 'G1', board_instance.board)
      expect(board_instance.board.flatten.none? { |p| p.is_a?(Rook) && p != Blank.new }).to be true
    end
  end

  describe '#en_passant' do
    it 'does not remove a pawn if conditions are not met' do
      board_instance.board[3][4] = Pawn.new(:white)
      board_instance.board[3][5] = Pawn.new(:black)
      white_pawn = board_instance.board[3][4]

      board_instance.instance_variable_set(:@en_passant, [1, 2]) # irrelevant move

      board_instance.en_passant(white_pawn, 'D4', 'D5', board_instance.board)

      expect(board_instance.board[3][5]).not_to be_a(Blank)
    end

    it 'resets @en_passant if not a pawn move' do
      bishop = Bishop.new(:white)
      board_instance.instance_variable_set(:@en_passant, [3, 3])

      board_instance.en_passant(bishop, 'C1', 'E3', board_instance.board)

      en_passant_val = board_instance.instance_variable_get(:@en_passant)
      expect(en_passant_val).to be_nil
    end
  end
end
