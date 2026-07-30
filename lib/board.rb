# frozen_string_literal: true

require_relative 'pieces'
require_relative 'player'

class Board
  Y_AXIS = %w[a b c d e f g h].freeze
  X_AXIS = (1..8).freeze
  SQUARE_SIZE = 5

  attr_reader :board

  def initialize
    @board = pop_board(:classic)
  end

  def render_board
    render_rows
    puts "   #{Array.new(8, '-' * SQUARE_SIZE).join('')}"
    row = ''
    ('a'..'h').each { |letter| row += letter.center(SQUARE_SIZE) }
    puts "    #{row}"
  end

  def move_piece(curr_player)
    from_coord = curr_player.move_from.to_sym
    piece = @board[from_coord]
    to_coord = curr_player.move_to.to_sym
    piece.legal_move?(to_coord)
  end

  def read_board
    init_board
  end

  private

  def init_board
    board = {}
    8.downto(1) do |y|
      1.upto(8) do |x|
        coord = [x, y]
        p coord
        board[coord] = nil
      end
    end
    board
  end

  def pop_board(icon)
    board = init_board
    board = pop_board_helper(board, :white, icon, 1, 2)
    pop_board_helper(board, :black, icon, 8, 7)
  end

  def pop_board_helper(board, player, icon, y_first, y_second)
    board.keys.filter_map { |coord| board[coord] = Pawn.new(player, icon) if coord[1] == y_second }
    board[[1, y_first]] = Rook.new(player, icon)
    board[[2, y_first]] = Knight.new(player, icon)
    board[[3, y_first]] = Bishop.new(player, icon)
    board[[4, y_first]] = Queen.new(player, icon)
    board[[5, y_first]] = King.new(player, icon)
    board[[6, y_first]] = Bishop.new(player, icon)
    board[[7, y_first]] = Knight.new(player, icon)
    board[[8, y_first]] = Rook.new(player, icon)
    board
  end

  def render_rows
    8.downto(1) do |rank|
      row = "#{rank} | "
      ('a'..'h').map do |file|
        piece = @board[(file + rank.to_s).to_sym]
        row += if piece.nil?
                 ' . '.center(SQUARE_SIZE)
               else
                 piece.icon.center(SQUARE_SIZE)
               end
      end
      puts row
    end
  end
end

player = Player.new(1, :white)
p Board.new.board
