class Piece
  ICONS = { pawn: { white: '♙', black: '♟' },
            knight: { white: '♘', black: '♞' },
            bishop: { white: '♗', black: '♝' },
            rook: { white: '♗', black: '♝' },
            queen: { white: '♕', black: '♛' },
            king: { white: '♔', black: '♚' } }.freeze

  def initialize(player, type)
    @player = player
    @type = type
    @icon = ICONS[player][type]
  end
end

class Pawn
end
