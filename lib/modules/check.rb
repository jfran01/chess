# frozen_string_literal: true

require_relative '../board'
require_relative '../pieces'
require_relative 'legal_movement'

module Check
  # if player is in check, returns coordinates of checking pieces
  def check?(colour, coord = find_piece_coords(King, colour)[0])
    checking_pieces = []
    checking_pieces.concat(knight_attacks[coord].select { |attacking_coord| enemy?(attacking_coord, colour, Knight) }) # good to go
    checking_pieces << straight_attack?(coord, colour) # good to go
    checking_pieces << diagonal_attack?(coord, colour) # good to go
    checking_pieces.concat(pawn_attack?(coord, colour))
    checking_pieces.reject!(&:empty?)
    return checking_pieces unless checking_pieces.empty?

    false
  end

  private

  def find_piece_coords(target_piece, colour)
    board.select { |_coord, piece| !piece.nil? && piece.instance_of?(target_piece) && piece.player == colour }.keys
  end

  def enemy?(coord, colour, piece)
    enemy_coord = board[coord]
    return true if enemy_coord && enemy_coord.player != colour && enemy_coord.instance_of?(piece)

    false
  end

  # good to go - returns all enemy Rooks, Bishops & Queen(s)
  def enemy_sliding_pieces(own_colour)
    pieces = []
    board.each do |coord, piece|
      pieces << [coord, piece] if !piece.nil? && piece.player != own_colour && (piece.is_a?(Rook) || piece.is_a?(Queen) || piece.is_a?(Bishop))
    end
    pieces
  end

  # good to go - returns coordinates of an enemy Rook or Queen with a clear path to own king, [] if none
  def straight_attack?(king_coord, king_colour)
    enemy_sliding_pieces(king_colour).each do |coord, piece|
      slide_through = piece.slide_straight(coord, king_coord) if piece.instance_of?(Rook) || piece.instance_of?(Queen)
      return coord if slide_through && slide_through.none? { |through| board[through] } # rubocop: disable Style/SafeNavigation
    end
    []
  end

  # good to go - returns coordinates of an enemy Bishop or Queen with a clear path to own king, [] if none
  def diagonal_attack?(king_coord, king_colour)
    enemy_sliding_pieces(king_colour).each do |coord, piece|
      slide_through = piece.slide_diagonal(coord, king_coord) if piece.instance_of?(Bishop) || piece.instance_of?(Queen)
      return coord if slide_through && slide_through.none? { |through| board[through] } # rubocop: disable Style/SafeNavigation
    end
    []
  end

  def pawn_attack?(king_coord, colour)
    return white_pawn_attacks[king_coord].select { |coord| enemy?(coord, colour, Pawn) } if colour == :white

    black_pawn_attacks[king_coord].select { |coord| enemy?(coord, colour, Pawn) }
  end

  def enemy_colour(colour)
    return :black if colour == :white

    :white
  end
end

module Checkmate
  include Check
  def avoid_checkmate(king_colour)
    king_coord = find_piece_coords(King, king_colour)&.first
    checking_pieces = check?(king_colour)
    move_from_pieces = []

    return false if checking_pieces.size > 1

    move_from_pieces << king_coord if escape_check?(king_coord, king_colour)

    block_coord = block_check(king_coord, king_colour, checking_pieces)
    block_coord.each { |coord| move_from_pieces << coord } if block_coord # rubocop:disable Style/SafeNavigation

    attack_coord = attack_check(king_colour, checking_pieces)
    attack_coord.each { |coord| move_from_pieces << coord } if attack_coord # rubocop:disable Style/SafeNavigation

    return move_from_pieces.uniq unless move_from_pieces.empty?

    false
  end

  # can king move out of check (without moving into another check); args = coords & colour of friendly king
  def escape_check?(king_coord, king_colour)
    adj_squares[king_coord].any? do |coord|
      !board[coord] && !check?(king_colour, coord)
    end
  end

  # can checking piece be blocked by a friendly piece; args = coords & colour of friendly king
  def block_check(king_coord, king_colour, checking_pieces)
    checking_coord = checking_pieces[0]
    checking_piece = board[checking_coord]
    through_coords = checking_piece.slide_straight(checking_coord, king_coord) if checking_piece.is_a?(Rook) || checking_piece.is_a?(Queen)
    if (checking_piece.is_a?(Bishop) || checking_piece.is_a?(Queen)) && !through_coords
      through_coords = checking_piece.slide_diagonal(checking_coord, king_coord)
    end
    through_coords.any? do |coord|
      result = block_check_helper(coord, king_colour)
      return result if result
    end
  end

  def pawn_block_check?(coord, king_colour)
    pawn_coord = if king_colour == :white
                   [coord[0], coord[1] - 1]
                 else
                   [coord[0], coord[1] + 1]
                 end
    return pawn_coord if board[pawn_coord].is_a?(Pawn) && board[pawn_coord].player == king_colour

    false
  end

  def block_check_helper(coord, king_colour)
    result = []
    knight_block = knight_attacks[coord].select do |attacking_coord|
      board[attacking_coord].is_a?(Knight) && board[attacking_coord].player == king_colour
    end
    result << knight_block unless knight_block.empty?

    straight_block = straight_attack?(coord, enemy_colour(king_colour))
    result << straight_block unless straight_block.empty?

    diagonal_block = diagonal_attack?(coord, enemy_colour(king_colour))
    result << diagonal_block unless diagonal_block.empty?

    pawn_block = pawn_block_check?(coord, king_colour)
    result << pawn_block if pawn_block

    return result unless result.empty?

    false
  end

  def attack_check(king_colour, checking_pieces)
    checking_coord = checking_pieces[0]
    result = check?(enemy_colour(king_colour), checking_coord)
    return result if result

    false
  end
end

module Stalemate
  def stalemate?(player_colour)
    return false if get_player_pieces(player_colour).any? do |coord, piece|
      can_piece_move_hash[piece.class].call(player_colour, coord)
    end

    true
  end

  def get_player_pieces(player_colour)
    board.reject { |piece| board[piece].nil? || board[piece].player != player_colour }
  end
end

board = Board.new
board.extend(Checkmate)
board.extend(GenAttackMaps)
board.init_attack_maps
board.board[[7, 7]] = Bishop.new(:black)
board.board[[6, 5]] = Pawn.new(:white)
board.board[[8, 4]] = Queen.new(:white)
board.board[[7, 6]] = Rook.new(:white)
board.board[[5, 5]] = King.new(:white)
board.render_board
p board.avoid_checkmate(:white)
