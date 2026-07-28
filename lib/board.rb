require_relative 'pieces'

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

  private

  def init_board
    board = {}
    X_AXIS.each do |x_coord|
      Y_AXIS.each do |y_coord|
        coord = y_coord + x_coord.to_s
        board[coord.to_sym] = nil
      end
    end
    board
  end

  def pop_board(icon)
    board = init_board
    board.each_key do |coord|
      case coord
      when /\w2/
        board[coord] = Pawn.new(:white, icon)
      when :a1, :h1
        board[coord] = Rook.new(:white, icon)
      when :b1, :g1
        board[coord] = Knight.new(:white, icon)
      when :c1, :f1
        board[coord] = Bishop.new(:white, icon)
      when :d1
        board[coord] = Queen.new(:white, icon)
      when :e1
        board[coord] = King.new(:white, icon)
      when /\w7/
        board[coord] = Pawn.new(:black, icon)
      when :a8, :h8
        board[coord] = Rook.new(:black, icon)
      when :b8, :g8
        board[coord] = Knight.new(:black, icon)
      when :c8, :f8
        board[coord] = Bishop.new(:black, icon)
      when :d8
        board[coord] = Queen.new(:black, icon)
      when :e8
        board[coord] = King.new(:black, icon)
      end
    end
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

board = Board.new
board.render_board
