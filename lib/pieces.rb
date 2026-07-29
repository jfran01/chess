class Piece
  ALPHABET_CONVERTER = ('a'..'z').each.with_index(1).to_h

  attr_reader :player

  def initialize(player, icon, coordinates)
    @player = player
    @coordinates = convert_coords(coordinates)
  end

  def convert_coords(coordinates)
    coordinates = coordinates.to_s.split('')
    coordinates[0] = Piece::ALPHABET_CONVERTER[coordinates[0]]
    coordinates[1] = coordinates[1].to_i
    coordinates
  end
end

class Pawn < Piece
  ICONS = { classic: { white: '♙', black: '♟' },
            letters: { white: 'WP', black: 'BP' } }.freeze

  attr_reader :icon

  def initialize(player, icon, coordinates)
    @icon = ICONS[icon][player]
    super
  end
end

class Rook < Piece
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

  def initialize(player, icon, coordinates)
    @icon = ICONS[icon][player]
    super
  end

  def find_adj
    offsets = [[2, 1], [-2, 1], [2, -1], [-2, -1], [1, 2], [-1, 2], [1, -2], [-1, -2]]
    adj_coordinates = offsets.map { |dx, dy| [@coordinates[0] + dx, @coordinates[1] + dy] }
    adj_coordinates.select! { |x, y| x < 8 && !x.negative? && y < 8 && !y.negative? }
    adj_coordinates
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
