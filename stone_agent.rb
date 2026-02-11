#stone_agent.rb

class StoneAgent
  attr_reader :stones

  def self.read(path)
    begin
      Pathname.new(path).open("rb") do |f|
        agent = Marshal.load(f)
      end
    rescue
      p $!
    end
  end

  def self.save(path, obj)
    begin
      Pathname.new(path).open("wb") do |f|
        Marshal.dump(obj, f)
      end
    rescue
      p $!
    end
  end

  def initialize
    # key = [state_key, action] => stone_count
    @stones = Hash.new(1)
  end

  # =========================
  # 行動選択（石ころが多い手を選ぶ）対戦用
  # =========================
  def choose_action_greedy(state, legal_actions)
    # 石ころが多い手を選ぶ（同数ならランダム）
    legal_actions.max_by do |a|
      @stones[[key(state), a]] + rand * 0.01
    end
  end

  # =========================
  # 行動選択（ルーレット）学習用
  # =========================
  # def choose_action(state, legal_actions)
  #   state_key = key(state)

  #   # 各行動の石ころ数を取得
  #   weights = legal_actions.map do |a|
  #     @stones[[state_key, a]]
  #   end

  #   total = weights.sum

  #   # 念のため（全ゼロ防止）
  #   if total <= 0
  #     return legal_actions.sample
  #   end

  #   r = rand * total
  #   acc = 0.0

  #   legal_actions.each_with_index do |a, i|
  #     acc += weights[i]
  #     return a if r <= acc
  #   end

  #   # 保険
  #   legal_actions.last
  # end

  def choose_action(state, legal_actions, epsilon = 0.2)
    state_key = key(state)

    if rand < epsilon
      # 探索
      legal_actions.sample
    else
      # 活用
      legal_actions.max_by { |a| @stones[[state_key, a]] }
    end
  end

# =========================
  # 報酬付与
  # =========================
  def reward!(history, result)
    base_reward =
      case result
      when :win  then [(3.0 - 0.1 * history.length), 1.0].max
      when :lose then [(-3.0 + 0.1 * history.length), -1.0].min
      else 0
      end

    history.each_with_index do |(state, action), i|
      k = [key(state), action]

      # 終盤ほど少し強く反映
      weight = (i + 1).to_f / history.length
      # 序盤ほど少し強く反映
      # weight = 1.0 - (i.to_f / history.size) * 0.5
      @stones[k] += base_reward * weight

      @stones[k] = 1 if @stones[k] < 1
    end
  end

  # =========================
  # state のキー化
  # =========================
  def key(state)
    # state は配列想定
    # 消える三目並べなら [:X, age] 等も含めてOK
    state.map do |cell|
      cell.nil? ? "_" : cell.to_s
    end.join
    # Marshal.dump(state)
  end

end
