require_relative '../lib/board'

describe Board do
  subject(:board) { described_class.new }

  describe '#initialize' do
    it 'creates an 8x8 board' do
      expect(board.board.size).to eq(8)
      board.board.each do |row|
        expect(row.size).to eq(8)
      end
    end

    it 'sets up pieces in the correct starting positions' do
      # Check the back row for white
      expect(board.board[0][0]).to be_a(Rook)
      expect(board.board[0][4]).to be_a(King)
      expect(board.board[0][4].color).to eq(:white)

      # Check the front row for white pawns
      board.board[1].each do |piece|
        expect(piece).to be_a(Pawn)
        expect(piece.color).to eq(:white)
      end

      # Check the back row for black
      expect(board.board[7][0]).to be_a(Rook)
      expect(board.board[7][4]).to be_a(King)
      expect(board.board[7][4].color).to eq(:black)

      # Check the front row for black pawns
      board.board[6].each do |piece|
        expect(piece).to be_a(Pawn)
        expect(piece.color).to eq(:black)
      end
    end

    it 'initializes with no player in check' do
      expect(board.in_check).to be_nil
    end
  end

  let(:board) { Board.new }

  describe "#get_possible_moves" do
    it "returns valid moves for a knight" do
      moves = board.get_possible_moves("B1")
      expect(moves).to include("A3", "C3")
    end
  end

  describe "#get_in_check_moves" do
    it "returns legal moves to block or escape check" do
      board = Board.new

      board.move_piece("E2", "E4")
      board.move_piece("D7", "D6")
      board.move_piece("D1", "E2")
      board.move_piece("F7", "F6")
      board.move_piece("E2", "H5")
      moves = board.get_in_check_moves("E8")

      # Now, test for moves to block or escape the check
      expect(moves).to include("D7") # Valid move to escape check
    end
  end

  describe "#add_possible_moves_colors" do
    it "colors moveable blank tiles" do
      moves = board.get_possible_moves("B1")
      board.add_possible_moves_colors(moves)
      colored_tile = board.tile_to_coordinate("C3")
      tile = board.board[colored_tile[0]][colored_tile[1]]
      expect(tile.color).to eq(Board::MOVEABLE_COLOR)
      expect(tile.symbol).to eq(Board::MOVEABLE_SYMBOL)
    end
  end

  describe "#revert_possible_moves_colors" do
    it "reverts colorized move tiles" do
      moves = board.get_possible_moves("B1")
      board.add_possible_moves_colors(moves)
      board.revert_possible_moves_colors("B1", :white)
      coord = board.tile_to_coordinate("C3")
      expect(board.board[coord[0]][coord[1]].color).not_to eq(Board::MOVEABLE_COLOR)
    end
  end

  describe "#move_piece" do
    it "moves a knight from B1 to C3" do
      board.move_piece("B1", "C3")
      expect(board.tile_to_piece("C3")).to be_a(Knight)
      expect(board.tile_to_piece("B1")).to be_a(Blank)
    end
  end

  describe "#change_piece_to" do
    it "promotes pawn to queen at given tile" do
      board.board[6][0] = Blank.new
      board.board[7][0] = Pawn.new(:white)
      board.change_piece_to("A8", :queen, :white)
      expect(board.tile_to_piece("A8")).to be_a(Queen)
    end
  end

  describe "#checkmate" do
    it "detects checkmate" do
      # Fool's mate setup
      board = Board.new
      board.move_piece("F2", "F3")
      board.move_piece("E7", "E5")
      board.move_piece("G2", "G4")
      board.move_piece("D8", "H4")
      expect(board.checkmate).to eq(:white)
    end
  end

  describe "#check" do
    it "sets in_check when king is attacked by a piece" do
      board = Board.new

      board.board[7][4] = Blank.new
      board.board[4][5] = Pawn.new(:black)
      board.board[5][5] = Pawn.new(:black)
      board.board[4][4] = King.new(:black)

      board.move_piece("D2", "D4")

      expect(board.in_check).to eq(:black)

    end
  end

  describe "#stalemate" do
    it "returns true when stalemate occurs" do
      board = Board.new
      board.board = Array.new(8) { Array.new(8) { Blank.new } }
      board.board[0][7] = King.new(:black)
      board.board[2][6] = Queen.new(:white)
      board.board[1][5] = King.new(:white)
      board.kings = [
        { king: board.board[1][5], position: [1, 5], threats: [] },
        { king: board.board[0][7], position: [0, 7], threats: [] }
      ]
      board.check
      expect(board.stalemate).to be true
    end
  end

  describe "#serialize" do
    it "returns a hash representing the board state" do
      result = board.serialize
      expect(result).to be_a(Hash)
      expect(result[:board]).to be_a(Array)
      expect(result[:board].flatten.compact.all? { |p| p.is_a?(Hash) || p.nil? }).to be true
    end
  end

  describe "#print_board" do
    it "prints the board" do
      expect { board.print_board }.to output(/A|B|C|D|E|F|G|H/).to_stdout
    end
  end

  describe "#valid_player_piece" do
    it "returns true for player's own piece" do
      expect(board.valid_player_piece("A2", :white)).to be true
    end

    it "returns false for opponent's piece" do
      expect(board.valid_player_piece("A7", :white)).to be false
    end
  end
end
