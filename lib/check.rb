module Check
  def check?(king_coord, colour)
    checking_pieces = []
    checking_pieces << knight_attacks[king_coord].select { |coord| enemy?(coord, colour, Knight) }
    checking_pieces << king_attacks[king_coord].select { |coord| enemy?(coord, colour, King) }
    checking_pieces << straight_attack?(king_coord, colour)
    checking_pieces << diagonal_attack?(king_coord, colour)
    checking_pieces << pawn_attack?(king_coord, colour)
    checking_pieces.reject!(&:empty?)
    return checking_pieces unless checking_pieces.empty?

    false
  end

  def escape_check?(king_coord, colour)
    mock_king = King.new(colour, :classic)
    king_attacks[king_coord].any? do |coord|
      !board[coord] && !check?(coord, mock_king, colour)
    end
  end

  def block_check?(king_coord)
    return unless @checking_pieces.size == 1
    return if king_attacks[king_coord].include?(@checking_pieces[0])

    checking_piece = board[@checking_pieces[0]]
    if checking_piece.instance_of?(Rook || Queen)
      through_coords = checking_piece.slide_straight(@checking_pieces[0], king_coord)
      p through_coords
    elsif checking_piece.instance_of?(Bishop || Queen)
      through_coords = checking_piece.slide_straight(@checking_pieces[0], king_coord)
    end
  end

  def find_king(colour)
    board.find { |_coord, piece| piece.instance_of?(King) && piece.player == colour }
  end

  private

  def enemy?(coord, colour, piece)
    enemy_coord = board[coord]
    return true if enemy_coord && enemy_coord.player != colour && enemy_coord.instance_of?(piece)

    false
  end

  def sliding_pieces(colour)
    pieces = []
    board.each do |coord, piece|
      if !piece.nil? && piece.player != colour && (piece.is_a?(Rook) || piece.is_a?(Queen) || piece.is_a?(Bishop))
        pieces << [coord, piece]
      end
    end
    pieces
  end

  def straight_attack?(king_coord, colour)
    sliding_pieces(colour).each do |coord, piece|
      slide_through = piece.slide_straight(coord, king_coord) if piece.instance_of?(Rook) || piece.instance_of?(Queen)
      return coord if slide_through && slide_through.none? { |through| board[through] }
    end
    []
  end

  def diagonal_attack?(king_coord, colour)
    sliding_pieces(colour).each do |coord, piece|
      slide_through = piece.slide_diagonal(coord, king_coord) if piece.instance_of?(Bishop) || piece.instance_of?(Queen)
      return coord if slide_through && slide_through.none? { |through| board[through] }
    end
    []
  end

  def pawn_attack?(king_coord, colour)
    return white_pawn_attacks[king_coord].select { |coord| enemy?(coord, colour, Pawn) } if colour == :white

    black_pawn_attacks[king_coord].select { |coord| enemy?(coord, colour, Pawn) }
  end
end
