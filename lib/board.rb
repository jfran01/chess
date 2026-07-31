# frozen_string_literal: true

require_relative 'pieces'
require_relative 'player'

class Board
  SQUARE_SIZE = 5

  attr_reader :board, :knight_attacks

  def initialize
    @board = pop_board(:classic)
    @knight_attacks = init_attack_maps([[2, 1], [-2, 1], [2, -1], [-2, -1], [1, 2], [-1, 2], [1, -2], [-1, -2]])
  end

  def render_board
    render_rows
    puts "   #{Array.new(8, '-' * SQUARE_SIZE).join('')}"
    row = ''
    ('a'..'h').each { |letter| row += letter.center(SQUARE_SIZE) }
    puts "   #{row}"
  end

  def move_piece(curr_player)
    from_coord = curr_player.move_from.to_sym
    piece = @board[from_coord]
    to_coord = curr_player.move_to.to_sym
    piece.legal_move?(to_coord)
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
    icons = @board.values.map do |value|
      if value.nil?
        '.'.center(SQUARE_SIZE)
      else
        value.icon.center(SQUARE_SIZE)
      end
    end
    rows = []
    icons.each_slice(8) { |slice| rows << slice.join }
    rows.each_with_index { |row, idx| puts "#{(idx + 1).to_s.ljust(2.5)}|#{row}" }
  end

  def init_attack_maps(offsets)
    map = {}
    board.each_key do |coord|
      adj = offsets.map { |dx, dy| [coord[0] + dx, coord[1] + dy] }
      adj.select! { |x, y| x.between?(1, 8) && y.between?(1, 8) }
      map[coord] = adj
    end
    map
  end
end

# Player.new(1, :white)
# p Board.new.knight_attacks
