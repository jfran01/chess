# frozen_string_literal: true

module CheckMoves
  def legal_move?(from, to, player_colour)
    piece = board[from]
    return false unless piece && piece.player == player_colour
    return false unless available_square(to, player_colour)
    return false unless move_triggers_check?(from, to, player_colour) == false
    return true if special_move?(piece, from, to)
    return false unless legal_slide?(piece, from, to)
    return false unless check_attack_maps(piece, from, to)
    return false if piece.instance_of?(Pawn) && !legal_pawn_move?(player_colour, from, to)

    true
  end

  def available_square(coord, player_colour)
    board[coord].nil? || board[coord].player != player_colour
  end

  def legal_slide?(piece, from, to)
    if piece.instance_of?(Rook)
      through_coords = piece.slide_straight(from, to)
    elsif piece.instance_of?(Bishop)
      through_coords = piece.slide_diagonal(from, to)
    elsif piece.instance_of?(Queen)
      through_coords = piece.slide_straight(from, to)
      through_coords << piece.slide_diagonal(from, to)
    else
      return true
    end
    return false if !through_coords || through_coords.any? { |coord| board[coord] }

    true
  end

  def check_attack_maps(piece, from, to)
    if piece.instance_of?(Knight)
      return true if knight_attacks[from].include?(to)
    elsif piece.instance_of?(King)
      return true if king_attacks[from].include?(to)
    elsif piece.instance_of?(Pawn)
      return true unless board[to]

      if piece.player == :white
        return true if white_pawn_attacks[from].include?(to)
      elsif piece.player == :black
        return true if black_pawn_attacks[from].include?(to)
      end
    elsif piece.instance_of?(Queen) || piece.instance_of?(Bishop) || piece.instance_of?(Rook)
      return true
    end
    false
  end

  def legal_pawn_move?(colour, from, to)
    return true if board[to]

    offset = to.zip(from).map { |a, b| a - b }
    if colour == :white
      return true if offset == [0, 1]
      return true if from[1] == 2 && offset == [0, 2]
    elsif colour == :black
      return true if offset == [0, -1]
      return true if from[1] == 7 && offset == [0, -2]
    end
    false
  end

  def move_triggers_check?(from, to, colour)
    captured_piece = board[to]
    move(from, to, capture_piece: false)
    result = check?(colour)
    move(to, from)
    board[to] = captured_piece
    result
  end
end

module MakeMove
  def move_piece(curr_player)
    moving_piece, from_coord, to_coord = next_move(curr_player)
    return :save_game if moving_piece == :save_game

    special_move = special_move?(moving_piece, from_coord, to_coord)
    if special_move
      special_moves_hash[special_move].call(moving_piece, from_coord, to_coord)
    else
      make_standard_move(moving_piece, from_coord, to_coord)
    end
    toggle_move_status(moving_piece)
  end

  def make_standard_move(moving_piece, from_coord, to_coord)
    captured_piece = board[to_coord]
    board[to_coord] = moving_piece
    board[from_coord] = nil
    return unless captured_piece

    puts "Congratulations! (and commiserations...) A #{captured_piece.player} #{captured_piece.class.to_s.downcase} has been captured."
    @captured_pieces << captured_piece
  end

  def next_move(curr_player)
    piece, from_coord = next_move_from(curr_player)
    return :save_game if piece == :save_game

    to_coord = next_move_to(curr_player, from_coord, piece)
    return :save_game if to_coord == :save_game

    puts "Moving #{piece.class.to_s.downcase} from #{convert_coord_to_notation(from_coord)} to #{convert_coord_to_notation(to_coord)}"
    [piece, from_coord, to_coord]
  end

  def next_move_from(curr_player)
    loop do
      from_coord = curr_player.move_from
      return :save_game if from_coord == :save_game

      piece = board[from_coord]
      if piece.nil?
        puts "You're trying to move a piece that doesn't exist. Get your act together c'mon..."
      elsif curr_player.colour != piece.player
        puts 'You cannot move from a square that does not contain a piece of your colour; use your own army, imperialist.'
      elsif !can_coord_be_moved_from?(from_coord)
        puts "That piece cannot move, like, at all... I'd reconsider if I were you..."
      else
        return [piece, from_coord]
      end
    end
  end

  def next_move_to(curr_player, from_coord, piece)
    to_coord = curr_player.move_to
    return :save_game if to_coord == :save_game

    until legal_move?(from_coord, to_coord, piece.player)
      converted_coords = [convert_coord_to_notation(from_coord), convert_coord_to_notation(to_coord)]
      puts "Your #{piece.class.to_s.downcase} cannot move from #{converted_coords[0]} to #{converted_coords[1]} without imploding. Try again."
      to_coord = curr_player.move_to
    end
    to_coord
  end

  def toggle_move_status(piece)
    return unless (piece.is_a?(King) || piece.is_a?(Rook)) && !piece.moved

    piece.moved = true
  end
end

module AttackMaps
  def init_attack_maps(offsets)
    map = {}
    board.each_key do |coord|
      adj = offsets.map { |dx, dy| [coord[0] + dx, coord[1] + dy] }
      adj.select! { |x, y| x.between?(1, 8) && y.between?(1, 8) }
      map[coord] = adj
    end
    map
  end
end

module Slideable
  def slide_straight(from, to)
    move = to.zip(from).map { |a, b| a - b }
    return false unless move.include?(0)

    through_coords = []
    if !move[0].zero?
      direction = move[0] <=> 0
      (move[0].abs - 1).times do |i|
        through_coords << [from[0] + (direction * (i + 1)), from[1]]
      end
    elsif !move[1].zero?
      direction = move[1] <=> 0
      (move[1].abs - 1).times do |i|
        through_coords << [from[0], from[1] + (direction * (i + 1))]
      end
    else
      return false
    end

    through_coords
  end

  def slide_diagonal(from, to)
    move = to.zip(from).map { |a, b| a - b }
    return false if move.include?(0) || move[0].abs != move[1].abs

    through_coords = []
    dx = move[0] <=> 0
    dy = move[1] <=> 0
    (move[0].abs - 1).times do |i|
      through_coords << [from[0] + (dx * (i + 1)), from[1] + (dy * (i + 1))]
    end
    through_coords
  end
end

module Castling
  def castling(moving_piece, from_coord, to_coord)
    rook_coord = castle_through(from_coord, to_coord)
    rook, old_rook_coord = castle_next_to_rook?(from_coord, to_coord)
    return false unless rook_coord && rook && old_rook_coord

    board[rook_coord] = rook
    board[old_rook_coord] = nil
    board[to_coord] = moving_piece
    board[from_coord] = nil
    true
  end

  def castling_coords?(from_coord, to_coord)
    if from_coord == [5, 1]
      return true if to_coord == [7, 1]
      return true if to_coord == [2, 1]
    elsif from_coord == [5, 8]
      return true if to_coord == [7, 8]
      return true if to_coord == [2, 8]
    end
    false
  end

  private

  def castle_through(from_coord, to_coord)
    colour = board[from_coord].player
    move = to_coord[0] - from_coord[0]
    dx = move <=> 0
    through = []
    (move.abs - 1).times do |i|
      through = [from_coord[0] + (dx * (i + 1)), from_coord[1]]
      return false if board[through]
      return false if check?(colour, through)
    end
    through
  end

  def castle_next_to_rook?(from_coord, to_coord)
    rook_coord = [from_coord[0] + 3, from_coord[1]]
    rook = board[rook_coord]
    return [rook, rook_coord] if rook.is_a?(Rook) && !rook.moved && [rook_coord[0] - 1, rook_coord[1]] == to_coord

    rook = board[rook_coord]
    rook_coord = [from_coord[0] - 4, from_coord[1]]
    return [rook, rook_coord] if rook.is_a?(Rook) && !rook.moved && [rook_coord[0] + 1, rook_coord[1]] == to_coord

    false
  end
end

module SpecialMoves
  include Castling

  def special_moves_hash
    { castle: lambda { |moving_piece, from_coord, to_coord|
      castling(moving_piece, from_coord, to_coord)
    }, en_passant: lambda { |moving_piece, from_coord, to_coord|
         en_passant(moving_piece, from_coord, to_coord)
       }, promotion: lambda { |moving_piece, from_coord, to_coord|
            promotion(moving_piece, from_coord, to_coord)
          } }
  end

  def special_move?(moving_piece, from_coord, to_coord)
    return :castle if moving_piece.is_a?(King) && !moving_piece.moved && castling_coords?(from_coord,
                                                                                          to_coord) && castling(moving_piece, from_coord, to_coord)
    return :en_passant if moving_piece.is_a?(Pawn) && legal_en_passant?(moving_piece, from_coord, to_coord)
    return :promotion if moving_piece.is_a?(Pawn) && promotion(moving_piece, from_coord, to_coord)

    false
  end

  def en_passant(moving_piece, from_coord, to_coord)
    captive_pawn_coord = captive_pawn_coord(moving_piece, from_coord, to_coord)[0]
    captured_piece = board[captive_pawn_coord]
    board[to_coord] = moving_piece
    board[from_coord] = nil
    return unless captured_piece

    puts "Congratulations! (and commiserations...) A #{captured_piece.player} #{captured_piece.class.to_s.downcase} has been captured."
    board[captive_pawn_coord] = nil
    @captured_pieces << captured_piece
  end

  def legal_en_passant?(captor_pawn, from_coord, to_coord)
    captive_pawn_coord, move = captive_pawn_coord(captor_pawn, from_coord, to_coord)
    return false unless captive_pawn_coord

    captive_pawn = board[captive_pawn_coord]
    return false if captive_pawn.nil?
    return false if captor_pawn.player == captive_pawn.player
    return false if captive_pawn.player == :white && captive_pawn_coord[1] != 4 && move[1] != 1
    return false if captive_pawn.player == :black && captive_pawn_coord[1] != 5 && move[1] != -1

    true
  end

  def captive_pawn_coord(captor_pawn, from_coord, to_coord)
    move = to_coord.zip(from_coord).map { |a, b| a - b }
    return false if captor_pawn.player == :white && [[-1, 1], [1, 1]].none? { |offset| offset == move }
    return false if captor_pawn.player == :black && [[-1, -1], [1, -1]].none? { |offset| offset == move }

    [[from_coord[0] + move[0], from_coord[1]], move]
  end

  def promotion(moving_piece, from_coord, to_coord)
    if moving_piece.player == :white && to_coord[1] == 8
      promote_pawn(:white, from_coord, to_coord)
    elsif moving_piece.player == :black && to_coord[1] == 1
      promote_pawn(:black, from_coord, to_coord)
    else
      false
    end
  end

  def promote_pawn(colour, from_coord, to_coord)
    puts 'Pawn has reached the farthest rank!! Time for a promotion; choose Queen, Bishop, Rook, or Knight.'
    piece = gets.chomp.capitalize
    board[to_coord] = piece.new(colour)
    board[from_coord] = nil
  end
end
