module Check
  def check?(colour, coord = find_piece_coords(King, colour))
    checking_pieces = []
    checking_pieces.concat(knight_attacks[coord].select { |attacking_coord| enemy?(attacking_coord, colour, Knight) })
    checking_pieces << straight_attack?(coord, colour)
    checking_pieces << diagonal_attack?(coord, colour)
    checking_pieces.concat(pawn_attack?(coord, colour))
    checking_pieces.reject!(&:empty?)
    return checking_pieces unless checking_pieces.empty?

    false
  end

  def checkmate?(colour)
    @checking_pieces = check?(colour)
    return unless @checking_pieces
    return false unless @checking_pieces.size == 1

    king_coord = find_piece_coords(King, colour)

    return false if escape_check?(king_coord, colour) == true

    p "can't escape check"
    return false if block_check?(king_coord, colour) == true

    p "can't block check"
    return false if attack_check?(colour) == true

    p "can't attack check with non king pieces"
    return false if king_attack_check?(@checking_pieces[0], colour) == true

    p "can't attack check with king"

    true
  end

  private

  def find_piece_coords(target_piece, colour)
    board.find { |_coord, piece| piece.instance_of?(target_piece) && piece.player == colour }&.first
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
    king_attacks[king_coord].any? do |coord|
      !board[coord] && !check?(colour, coord)
    end
  end

  # can checking piece be blocked by a friendly piece; args = coords & colour of friendly king
  def block_check?(king_coord, colour)
    checking_piece = board[@checking_pieces[0]]
    if checking_piece.instance_of?(Rook) || checking_piece.instance_of?(Queen)
      through_coords = checking_piece.slide_straight(@checking_pieces[0], king_coord)
    end
    if checking_piece.instance_of?(Bishop) || checking_piece.instance_of?(Queen) && !through_coords
      through_coords = checking_piece.slide_diagonal(@checking_pieces[0], king_coord)
    end
    through_coords.each do |coord|
      p coord
      return true if check?(enemy_colour(colour), coord) # change from check
    end
  end

  def block_check_helper(coord, colour)
    return true if knight_attacks[coord].any?{|attacking_coord| enemy?(attacking_coord, colour, Knight)}
    return true if straight_attack?(coord, colour)
    return true if diagonal_attack?(coord, colour)
    return true if 
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
