class Piece
  ICONS = { pawn: { white: '♙', black: '♟' },
            knight: { white: '♘', black: '♞' },
            bishop: { white: '♗', black: '♝' },
            rook: { white: '♗', black: '♝' },
            queen: { white: '♕', black: '♛' },
            king: { white: '♔', black: '♚' } }.freeze

  attr_reader :player

  def initialize(player, icon)
    @player = player
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
