# frozen_string_literal: true

module Check
  def check?(colour, coord = find_piece_coords(King, colour)[0])
    checking_pieces = []
    checking_pieces.concat(knight_attacks[coord].select { |attacking_coord| enemy?(attacking_coord, colour, Knight) })
    checking_pieces << straight_attack?(coord, colour)
    checking_pieces << diagonal_attack?(coord, colour)
    checking_pieces.concat(pawn_attack?(coord, colour))
    checking_pieces.reject!(&:empty?)
    return checking_pieces unless checking_pieces.empty?

    false
  end

  def checkmate?(king_colour)
    @checking_pieces = check?(king_colour)
    return true unless @checking_pieces.size == 1

    king_coord = find_piece_coords(King, king_colour)&.first

    return false if escape_check?(king_coord, king_colour) == true
    return false if attack_check?(king_colour) == true
    return false if block_check?(king_coord, king_colour) == true
    return false if king_attack_check?(@checking_pieces[0], king_colour) == true

    true
  end

  private

  def find_piece_coords(target_piece, colour)
    board.select { |_coord, piece| piece.instance_of?(target_piece) && piece.player == colour }.keys
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
    if (checking_piece.instance_of?(Bishop) || checking_piece.instance_of?(Queen)) && !through_coords
      through_coords = checking_piece.slide_diagonal(@checking_pieces[0], king_coord)
    end
    through_coords.any? do |coord|
      block_check_helper(coord, colour)
    end
  end

  def block_check_helper(coord, king_colour)
    return true if knight_attacks[coord].any? do |attacking_coord|
      board[attacking_coord].is_a?(Knight) && board[attacking_coord].player == king_colour
    end
    return true unless straight_attack?(coord, enemy_colour(king_colour)).empty?
    return true unless diagonal_attack?(coord, enemy_colour(king_colour)).empty?
    return true if pawn_block_check?(coord, king_colour)

    false
  end

  def pawn_block_check?(coord, colour)
    if colour == :white
      coord[1] -= 1
    else
      coord[1] += 1
    end
    return true if board[coord].is_a?(Pawn) && board[coord].player == colour
    return true if [3, 6].include?(coord[1]) && pawn_block_check?(coord, colour)

    false
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

module Stalemate
  def stalemate?(king_colour)
    # occurs when there are no legal moves that the player of that colour can make
    # solution 1: find all pieces of that player and check for legal moves
    # King: use king_attacks map, with output of find_piece_coords as key
    king_coord = find_piece_coords(King, king_colour)[0]
    # # can any associated coords be moved to legally? ie aren't occupied & aren't in check
    return false if king_attacks[king_coord].any? do |coord|
      (board[coord].nil? || board[coord].player != king_colour) && !check?(king_colour, coord)
    end

    knight_coords = find_piece_coords(Knight, king_colour)
    return false if knight_coords.any? do |knight_coord|
      knight_attacks[knight_coord].any? { |coord| board[coord].nil? || board[coord].player != king_colour }
    end

    # sliding_pieces finds all enemy sliding pieces, we must therefore invert the colour to get those matching our current king
    sliding_piece_coords = sliding_pieces(enemy_colour(king_colour)).map(&:first)
  end

  # can king move?
  def king_can_move?(player_colour)
    king_coord = find_piece_coords(King, player_colour)[0]
    king_attacks[king_coord].any? do |coord|
      available_square(coord, player_colour) && !check(player_colour, coord)
    end
  end

  # can any knights move?
  # can any sliding pieces move?
  # can any pawns move?
  # is there an available square- either nil or occupied by an enemy piece?
  def available_square(coord, player_colour)
    board[coord].nil? || board[coord].player != player_colour
  end
end
