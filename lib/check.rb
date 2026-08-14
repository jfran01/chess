# frozen_string_literal: true

module Check
  def check?(colour, coord = find_piece_coords(King, colour)[0])
    checking_pieces = []
    checking_pieces.concat(knight_attacks[coord].select { |attacking_coord| enemy?(attacking_coord, colour, Knight) })
    checking_pieces.concat(king_attacks[coord].select { |attacking_coord| enemy?(attacking_coord, colour, King) })
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
    attack_check_pieces = check?(enemy_colour(colour), @checking_pieces[0])
    true if attack_check_pieces && attack_check_pieces.none? { |piece| board[piece].is_a?(King) } # rubocop:disable Style/SafeNavigation
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
    return false if king_or_queen_can_move?(king_colour, King)
    return false if king_or_queen_can_move?(king_colour, Queen)
    return false if knight_can_move?(king_colour)
    return false if sliding_piece_can_move?(king_colour, Rook, [[1, 0], [-1, 0], [0, 1], [0, -1]])
    return false if sliding_piece_can_move?(king_colour, Bishop, [[1, 1], [1, -1], [-1, -1], [-1, 1]])
    return false if pawn_can_move?(king_colour)

    true
  end

  # can king move?
  def king_or_queen_can_move?(player_colour, piece_type)
    # king_attacks map checks all immediate squares, a queen must be able to legally move to an immediate square
    piece_coord = find_piece_coords(piece_type, player_colour)[0]
    return false unless piece_coord

    king_attacks[piece_coord].any? do |move_to|
      legal_move?(piece_coord, move_to, player_colour)
    end
  end

  # can any knights move?
  def knight_can_move?(player_colour)
    find_piece_coords(Knight, player_colour).any? do |knight_coord|
      knight_attacks[knight_coord].any? { |move_to| legal_move?(knight_coord, move_to, player_colour) }
    end
  end

  # can any sliding pieces move?
  def sliding_piece_can_move?(player_colour, piece_type, offsets)
    find_piece_coords(piece_type, player_colour).any? do |piece_coord|
      adj_coords = offsets.map { |dx, dy| [piece_coord[0] + dx, piece_coord[1] + dy] }
      adj_coords.select! { |x, y| x.between?(1, 8) && y.between?(1, 8) }
      adj_coords.any? { |move_to| legal_move?(piece_coord, move_to, player_colour) }
    end
  end

  # can any pawns move?
  def pawn_can_move?(player_colour)
    find_piece_coords(Pawn, player_colour).any? do |pawn_coord|
      move_to = pawn_coord
      move_to[1] += if player_colour == :white
                      1
                    else
                      -1
                    end
      !board[move_to].nil? || board[move_to] != player_colour
    end
  end
end
