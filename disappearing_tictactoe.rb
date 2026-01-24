# disappearing_tictactoe.rb

class DisappearingTicTacToe
  attr_reader :winner, :board

  MAX_AGE = 3   # 3手で消える

  def initialize
    reset
  end

  # =========================
  # ゲーム初期化
  # =========================
  def reset
    # 各マス: nil または [:X, age]
    @board = Array.new(9)
    @current_player = :X
    @winner = nil
    @turn = 0
  end

  # =========================
  # 現在の状態
  # =========================
  def state
    @board.map do |cell|
      cell.nil? ? nil : [cell[0], cell[1]]
    end
  end

  # =========================
  # 合法手
  # =========================
  def legal_actions
    @board.each_index.select { |i| @board[i].nil? }
  end

  # =========================
  # 1手進める
  # =========================
  def play(pos)
    raise "Illegal move" unless legal_actions.include?(pos)

    age_all_stones
    @board[pos] = [@current_player, 0]
    @turn += 1

    check_winner
    switch_player unless over?
  end

  # =========================
  # ゲーム終了判定
  # =========================
  def over?
    return true if @winner
    legal_actions.empty?
  end

  # =========================
  # 結果（StoneAgent 用）
  # =========================
  def result
    return :win  if @winner == :X
    return :lose if @winner == :O
    :draw
  end

  def display
    @board.each_with_index{|b, i|
      print " |" if (i % 3) == 0
      print b.nil? ? ((i + 1).to_s + "|") : (b[0].to_s + "|")
      print "\n" if (i % 3) == 2
    }
  end

  # =========================
  # 内部処理
  # =========================
  private

  def age_all_stones
    @board.each_with_index do |cell, i|
      next if (cell == nil || cell[0] != @current_player)
      cell[1] += 1
      @board[i] = nil if cell[1] >= MAX_AGE
    end
  end

  def switch_player
    @current_player = (@current_player == :X ? :O : :X)
  end

  def check_winner
    lines = [
      [0,1,2],[3,4,5],[6,7,8],
      [0,3,6],[1,4,7],[2,5,8],
      [0,4,8],[2,4,6]
    ]

    lines.each do |a, b, c|
      cells = [@board[a], @board[b], @board[c]]
      next if cells.any?(&:nil?)
      if cells.map(&:first).uniq.size == 1
        @winner = cells.first.first
        return
      end
    end
  end
end
