module Check
  def check?(colour, coord = find_king_coord(colour))
    checking_pieces = []
    checking_pieces << knight_attacks[coord].select { |attacking_coord| enemy?(attacking_coord, colour, Knight) }
    checking_pieces << straight_attack?(coord, colour)
    checking_pieces << diagonal_attack?(coord, colour)
    checking_pieces << pawn_attack?(coord, colour)
    checking_pieces.reject!(&:empty?)
    return checking_pieces unless checking_pieces.empty?

    false
  end

  def checkmate?(colour)
    return false unless @checking_pieces.size == 1

    king_coord = find_king_coord(colour)

    return true if escape_check?(king_coord, colour) == true
    return true if block_check?(king_coord, colour) == true
    return true if attack_check?(colour) == true
    return true if king_attack_check?(@checking_pieces[0], colour) == true

    false
  end

  private

  def find_king_coord(colour)
    board.find { |_coord, piece| piece.instance_of?(King) && piece.player == colour }&.first
  end

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
      return coord if slide_through && slide_through.none? { |through| board[through] } # rubocop: disable Style/SafeNavigation
    end
    []
  end

  def diagonal_attack?(king_coord, colour)
    sliding_pieces(colour).each do |coord, piece|
      slide_through = piece.slide_diagonal(coord, king_coord) if piece.instance_of?(Bishop) || piece.instance_of?(Queen)
      return coord if slide_through && slide_through.none? { |through| board[through] } # rubocop: disable Style/SafeNavigation
    end
    []
  end

  def pawn_attack?(king_coord, colour)
    return white_pawn_attacks[king_coord].select { |coord| enemy?(coord, colour, Pawn) } if colour == :white

    black_pawn_attacks[king_coord].select { |coord| enemy?(coord, colour, Pawn) }
  end

  # can king move out of check (without moving into another check); args = coords & colour of friendly king
  def escape_check?(king_coord, colour)
    mock_king = King.new(colour, :classic)
    king_attacks[king_coord].any? do |coord|
      !board[coord] && !check?(coord, mock_king, colour)
    end
  end

  # can checking piece be blocked by a friendly piece; args = coords & colour of friendly king
  def block_check?(king_coord, colour)
    checking_piece = board[@checking_pieces[0]]
    if checking_piece.instance_of?(Rook || Queen)
      through_coords = checking_piece.slide_straight(@checking_pieces[0], king_coord)
    elsif checking_piece.instance_of?(Bishop || Queen)
      through_coords = checking_piece.slide_diagonal(@checking_pieces[0], king_coord)
    end
    through_coords.each do |coord|
      return true if check?(coord, colour)
    end
  end

  # can checking piece be taken by a friendly piece; args = colour of friendly king
  def attack_check?(colour)
    true if check?(enemy_colour(colour), @checking_pieces[0])
  end

  # can king take the checking piece without moving into check
  def king_attack_check?(checking_coord, colour)
    return true if king_attacks[checking_coord].any? do |coord|
      enemy?(coord, colour, King)
    end && !check?(enemy_colour(colour), checking_coord)

    false
  end

  def enemy_colour(colour)
    return :black if colour == :white

    :white
  end
end
