# frozen_string_literal: true

require_relative 'pieces'
require_relative 'player'
require_relative 'modules/movement'
require_relative 'modules/check'
require_relative 'modules/can_piece_move'

class Board
  include CheckMoves
  include AttackMaps
  include Check
  include Stalemate
  include PieceMoveability
  SQUARE_SIZE = 5

  attr_reader :board, :knight_attacks, :king_attacks, :white_pawn_attacks, :black_pawn_attacks
  attr_accessor :checking_pieces

  def initialize
    @board = init_board
    pop_board(:classic)
    @knight_attacks = init_attack_maps([[2, 1], [-2, 1], [2, -1], [-2, -1], [1, 2], [-1, 2], [1, -2], [-1, -2]])
    @king_attacks = init_attack_maps([[0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1]])
    @white_pawn_attacks = init_attack_maps([[-1, 1], [1, 1]])
    @black_pawn_attacks = init_attack_maps([[-1, -1], [1, -1]])
    @captured_pieces = []
  end

  def render_board
    puts "\n"
    render_rows
    puts "   #{Array.new(8, '-' * SQUARE_SIZE).join('')}"
    row = ''
    ('a'..'h').each { |letter| row += letter.center(SQUARE_SIZE) }
    puts "   #{row}"
  end

  def move(from, to, capture_piece: true)
    @captured_pieces << board[to] unless board[to].nil? || !capture_piece
    board[to] = board[from]
    board[from] = nil
  end

  private

  def init_board
    board = {}
    8.downto(1) do |y|
      1.upto(8) do |x|
        coord = [x, y]
        board[coord] = nil
      end
    end
    board
  end

  def pop_board(icon)
    @board = pop_board_helper(@board, :white, icon, 1, 2)
    @board = pop_board_helper(@board, :black, icon, 8, 7)
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
    icons = @board.values.map do |value|
      if value.nil?
        '.'.center(SQUARE_SIZE)
      else
        value.icon.center(SQUARE_SIZE)
      end
    end
    rows = []
    icons.each_slice(8) { |slice| rows << slice.join }
    rows.each_with_index { |row, idx| puts "#{(8 - idx).to_s.ljust(2.5)}|#{row}" }
  end
end
