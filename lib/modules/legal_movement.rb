module PawnMoves
  def legal_pawn_move?(colour, from_coord, to_coord)
    move = to_coord.zip(from_coord).map { |a, b| a - b }
    offset = move.map { |i| i <=> 0 }
    return false if colour == :white && offset[1].negative?
    return false if colour == :black && !offset[1].negative?

    return false unless legal_pawn_steps?(colour, from_coord, move) == true

    return true if legal_pawn_attack?(colour, from_coord, to_coord) == true
    return false unless board[to_coord].nil?
    return true if legal_en_passant?(colour, from_coord, to_coord) == true

    return false if offset[0].abs != 0

    true
  end

  def legal_pawn_attack?(colour, from_coord, to_coord)
    if colour == :white && white_pawn_attacks[from_coord].include?(to_coord)
      return true if !board[to_coord].nil? && board[to_coord].player == :black
    elsif colour == :black && black_pawn_attacks[from_coord].include?(to_coord)
      return true if !board[to_coord].nil? && board[to_coord].player == :white
    end
    false
  end

  def legal_pawn_steps?(colour, from_coord, move)
    return true if move[1].abs == 1

    return false unless move[1].abs == 2 && move[0].zero?

    if colour == :white && from_coord[1] == 2
      board[from_coord].en_passant_capture = true
      return true
    elsif colour == :black && from_coord[1] == 7
      board[from_coord].en_passant_capture = true
      return true
    end

    false
  end

  def legal_en_passant?(colour, from_coord, to_coord)
    if colour == :white
      return false unless from_coord[1] == 5
      return false unless white_pawn_attacks[from_coord].include?(to_coord)
    elsif colour == :black
      return false unless from_coord[1] == 4
      return false unless black_pawn_attacks[from_coord].include?(to_coord)
    end

    adj_pawn = adj_pawn?(colour, from_coord)
    return false unless adj_pawn&.en_passant_capture

    true
  end

  def adj_pawn?(colour, from_coord)
    [1, -1].any? do |x|
      adj_coord = from_coord.dup
      adj_coord[0] += x
      adj_piece = board[adj_coord]
      return adj_piece if adj_piece.is_a?(Pawn) && adj_piece.player != colour
    end
  end

  def promotion(colour, from_coord, to_coord)
    return unless legal_promotion?(colour, to_coord)

    puts 'Pawn has reached the farthest rank!! Time for a promotion; choose Queen, Bishop, Rook, or Knight.'
    piece_choice = assign_piece(gets.chomp.downcase)
    board[to_coord] = piece_choice.new(colour)
    board[from_coord] = nil
  end

  def legal_promotion?(colour, to_coord)
    return false if colour == :white && to_coord[1] != 8
    return false if colour == :black && to_coord[1] != 1

    true
  end

  def assign_piece(piece_choice)
    piece_types = { 'q': Queen, 'r': Rook, 'b': Bishop, 'kn': Knight }
    piece_types[piece_choice[0].to_sym]
  end
end

module SlidingMoves
  def legal_slide?(moving_piece, from_coord, to_coord)
    return false unless moving_piece.is_a?(Rook) || moving_piece.is_a?(Queen) || moving_piece.is_a?(Bishop)

    move = to_coord.zip(from_coord).map { |x, y| x - y }
    return false unless legal_sliding_dir?(moving_piece, move)
    return false unless through_coords(from_coord, to_coord, move).all? { |coord| board[coord].nil? }

    true
  end

  def through_coords(from_coord, to_coord, move)
    offset = move.map { |x| x <=> 0 }
    through_coord = from_coord
    all_through_coords = []
    until through_coord == to_coord
      through_coord = through_coord.zip(offset).map { |a, b| a + b }

      all_through_coords << through_coord
    end
    all_through_coords.pop
    all_through_coords
  end

  def legal_sliding_dir?(moving_piece, move)
    return true if move.any?(0) && (moving_piece.is_a?(Rook) || moving_piece.is_a?(Queen))
    return true if on_a_diagonal?(move) && (moving_piece.is_a?(Bishop) || moving_piece.is_a?(Queen))

    false
  end

  def on_a_diagonal?(move)
    move.map(&:abs).uniq.size == 1
  end
end

module Castling
  def legal_castling?(moving_piece, from_coord, to_coord)
    return false unless moving_piece.is_a?(King) && !moving_piece.moved

    move = from_coord.zip(to_coord).map { |a, b| b - a }
    return false unless [[2, 0], [-3, 0]].include?(move)

    offset = move.map { |x| x <=> 0 }
    return false unless castle_through(move, offset, from_coord)

    return false unless next_to_rook(offset, to_coord)

    true
  end

  def castle_through(move, offset, from_coord)
    through_coord = from_coord.dup
    move[0].abs.times do
      through_coord[0] = through_coord[0] + offset[0]
      return false unless board[through_coord].nil?
    end
  end

  def next_to_rook(offset, to_coord)
    rook_coord = to_coord.dup
    rook_coord[0] += offset[0]
    adj_rook = board[rook_coord]
    return adj_rook if adj_rook.is_a?(Rook) && !adj_rook.moved

    false
  end
end

module GenAttackMaps
  def init_attack_maps
    @adj_squares = attack_maps_helper([[0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1]])
    @knight_attacks = attack_maps_helper([[2, 1], [-2, 1], [2, -1], [-2, -1], [1, 2], [-1, 2], [1, -2], [-1, -2]])
    @white_pawn_attacks = attack_maps_helper([[-1, 1], [1, 1]])
    @black_pawn_attacks = attack_maps_helper([[-1, -1], [1, -1]])
  end

  def attack_maps_helper(offsets)
    map = {}
    board.each_key do |coord|
      adj = offsets.map { |dx, dy| [coord[0] + dx, coord[1] + dy] }
      adj.select! { |x, y| x.between?(1, 8) && y.between?(1, 8) }
      map[coord] = adj
    end
    map
  end
end

module LegalMoveTo
  include PawnMoves
  include SlidingMoves
  include Castling
  def legal_move_to?(moving_piece, from_coord, to_coord)
    colour = moving_piece.player
    return false if board[from_coord].nil?
    return false unless empty_or_enemy?(to_coord, colour)
    return false if check_for_adj_king(to_coord, colour)
    return false if move_triggers_check(from_coord, to_coord, colour)

    return true if moving_piece.is_a?(Pawn) && legal_pawn_move?(colour, from_coord, to_coord)
    return true if moving_piece.is_a?(Knight) && knight_attacks[from_coord].include?(to_coord)
    return true if moving_piece.is_a?(King) && adj_squares[from_coord].include?(to_coord)
    return true if legal_slide?(moving_piece, from_coord, to_coord)
    return true if legal_castling?(moving_piece, from_coord, to_coord)

    false
  end

  def check_for_adj_king(to_coord, colour)
    adj_squares[to_coord].any? { |adj_coord| board[adj_coord].is_a?(King) && board[adj_coord].player != colour }
  end

  def empty_or_enemy?(coord, colour)
    return false if board[coord] && board[coord].player == colour

    true
  end

  def move_triggers_check(from_coord, to_coord, colour)
    stub_movement(from_coord, to_coord) { check?(colour) }
  end

  def stub_movement(from_coord, to_coord)
    stored_capture = board[to_coord]
    board[to_coord] = board[from_coord]
    board[from_coord] = nil
    result = yield
    board[from_coord] = board[to_coord]
    board[to_coord] = stored_capture
    result
  end
end

module LegalMoveFrom
  def legal_move_from?(moving_piece, from_coord)
    all_possible_moves = all_possible_moves(moving_piece, from_coord)
    return false unless all_possible_moves

    all_possible_moves.any? { |move| legal_move_to?(moving_piece, from_coord, move) }
  end

  def all_possible_moves(moving_piece, from_coord)
    return adj_squares[from_coord] if moving_piece.is_a?(King) || moving_piece.is_a?(Queen)
    return possible_sliding_moves(from_coord, [[1, 1], [1, -1], [-1, -1], [-1, 1]]) if moving_piece.is_a?(Bishop)
    return possible_sliding_moves(from_coord, [[0, 1], [0, -1], [1, 0], [-1, 0]]) if moving_piece.is_a?(Rook)
    return knight_attacks[from_coord] if moving_piece.is_a?(Knight)
    return possible_pawn_moves(from_coord, moving_piece.player) if moving_piece.is_a?(Pawn)

    false
  end

  def possible_sliding_moves(from_coord, offset)
    offset.map! do |x, y|
      [from_coord[0] + x, from_coord[1] + y]
    end
    offset.select { |x, y| x.between?(1, 8) && y.between?(1, 8) }
  end

  def possible_pawn_moves(from_coord, colour)
    if colour == :white
      moves = [[from_coord[0], from_coord[1] + 1]]
      moves.concat(white_pawn_attacks[from_coord])
    elsif colour == :black
      moves = [[from_coord[0], from_coord[1] - 1]]
      moves.concat(black_pawn_attacks[from_coord])
    end
    moves
  end
end

# module Slideable
#   def slide_straight(from, to)
#     move = to.zip(from).map { |a, b| a - b }
#     return false unless move.include?(0)

#     through_coords = []
#     if !move[0].zero?
#       direction = move[0] <=> 0
#       (move[0].abs - 1).times do |i|
#         through_coords << [from[0] + (direction * (i + 1)), from[1]]
#       end
#     elsif !move[1].zero?
#       direction = move[1] <=> 0
#       (move[1].abs - 1).times do |i|
#         through_coords << [from[0], from[1] + (direction * (i + 1))]
#       end
#     else
#       return false
#     end

#     through_coords
#   end

#   def slide_diagonal(from, to)
#     move = to.zip(from).map { |a, b| a - b }
#     return false if move.include?(0) || move[0].abs != move[1].abs

#     through_coords = []
#     dx = move[0] <=> 0
#     dy = move[1] <=> 0
#     (move[0].abs - 1).times do |i|
#       through_coords << [from[0] + (dx * (i + 1)), from[1] + (dy * (i + 1))]
#     end
#     through_coords
#   end
# end
