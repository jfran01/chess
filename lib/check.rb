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

  def straight_attack?(king_coord, king)
    straight_coords = []
    board.each do |coord, piece|
      if !piece.nil? && piece.player != king.player && (piece.is_a?(Rook) || piece.is_a?(Queen))
        straight_slider_coords << coord
      end
    end
    straight_coords.each do |coord|
      slide_through = king.slide_straight(king_coord, coord)
      return true if slide_through && slide_through.none? { |through| board[through] } # rubocop: disable Style/SafeNavigation
    end
    false
  end

  def diagonal_attack?(king_coord, king)
    diagonal_coords = []
    board.each do |coord, piece|
      if !piece.nil? && piece.player != king.player && (piece.is_a?(Bishop) || piece.is_a?(Queen))
        diagnal_coords << coord
      end
    end
    diagonal_coords.each do |coord|
      slide_through = king.slide_diagonal(king_coord, coord)
      return true if slide_through && slide_through.none? { |through| board[through] } # rubocop: disable Style/SafeNavigation
    end
    false
  end
end
