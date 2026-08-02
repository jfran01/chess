module Check
  def check(colour)
    king_coord, piece = board.find { |_coord, piece| piece.instance_of?(King) && piece.player == colour }
    board[[3, 2]] = Knight.new(:white, :classic)
    board[[5, 3]] = King.new(:black, :classic)
    return true if knight_attacks[king_coord].any? { |coord| enemy?(coord, colour, Knight) }
    return true if king_attacks[king_coord].any? { |coord| enemy?(coord, colour, King) }

    false
  end

  def enemy?(coord, colour, piece)
    enemy_coord = board[coord]
    return true if enemy_coord && enemy_coord.player != colour && enemy_coord.instance_of?(piece)

    false
  end
end
