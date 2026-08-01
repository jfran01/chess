require_relative 'movement'

class Piece
  ALPHABET_CONVERTER = ('a'..'z').each.with_index(1).to_h

  attr_reader :player

  def initialize(player, _icon)
    @player = player
  end

  def legal_move?(square_to)
    square_to = convert_coords(square_to)
    return true if @adj_coordinates.include?(square_to)

    false
  end
end

class Pawn < Piece
  ICONS = { classic: { white: '♙', black: '♟' },
            letters: { white: 'WP', black: 'BP' } }.freeze

  attr_reader :icon

  def initialize(player, icon)
    @icon = ICONS[icon][player]
    super
  end
end

class Rook < Piece
  include Slideable

  ICONS = { classic: { white: '♖', black: '♜' },
            letters: { white: 'WR', black: 'BR' } }.freeze

  attr_reader :icon

  def initialize(player, icon)
    @icon = ICONS[icon][player]
    super
  end
end

class Knight < Piece
  ICONS = { classic: { white: '♘', black: '♞' },
            letters: { white: 'WN', black: 'BN' } }.freeze

  attr_reader :icon

  def initialize(player, icon)
    @icon = ICONS[icon][player]
    super
    # find_adj
  end

  def find_adj
    offsets = [[2, 1], [-2, 1], [2, -1], [-2, -1], [1, 2], [-1, 2], [1, -2], [-1, -2]]
    @adj_coordinates = offsets.map { |dx, dy| [@coordinates[0] + dx, @coordinates[1] + dy] }
    @adj_coordinates.select! { |x, y| x < 8 && !x.negative? && y < 8 && !y.negative? }
  end
end

class Bishop < Piece
  ICONS = { classic: { white: '♗', black: '♝' },
            letters: { white: 'WB', black: 'BB' } }.freeze

  attr_reader :icon

  def initialize(player, icon)
    @icon = ICONS[icon][player]
    super
  end
end

class Queen < Piece
  ICONS = { classic: { white: '♕', black: '♛' },
            letters: { white: 'WQ', black: 'BQ' } }.freeze

  attr_reader :icon

  def initialize(player, icon)
    @icon = ICONS[icon][player]
    super
  end
end

class King < Piece
  ICONS = { classic: { white: '♔', black: '♚' },
            letters: { white: 'WK', black: 'BK' } }.freeze

  attr_reader :icon

  def initialize(player, icon)
    @icon = ICONS[icon][player]
    super
  end
end

p Rook.new(:white, :classic).slide_straight([3, 7], [6, 5])
p Rook.new(:white, :classic).slide_straight([1, 1], [1, 1])
