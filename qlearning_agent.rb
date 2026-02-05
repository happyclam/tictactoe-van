#qlearning_agent.rb

class QLearningAgent
  ALPHA = 0.1   # 学習率
  GAMMA = 0.9   # 割引率
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

  def choose_action_greedy(state, legal_actions)
    # 石ころが多い手を選ぶ（同数ならランダム）
    legal_actions.max_by do |a|
      @stones[[key(state), a]] + rand * 0.01
    end
  end

  def choose_action(state, legal_actions, epsilon = 0.2)
    state_key = key(state)

    if rand < epsilon
      # 探索
      legal_actions.sample
    else
      # 各行動の石ころ数を取得
      weights = legal_actions.map do |a|
        @stones[[state_key, a]]
      end

      total = weights.sum

      # 念のため（全ゼロ防止）
      if total <= 0
        return legal_actions.sample
      end

      r = rand * total
      acc = 0.0

      legal_actions.each_with_index do |a, i|
        acc += weights[i]
        return a if r <= acc
      end
      # 保険
      legal_actions.last
    end
  end
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

  def learn!(state, action, reward, next_state, next_actions)
    s  = key(state)
    a  = action
    sa = [s, a]

    # 現在のQ
    q = @stones[sa]
    # p "q = #{q}"
    # 次状態の最大Q
    max_next_q =
      if next_actions.empty?
        0
      else
        next_actions.map { |na|
          @stones[[key(next_state), na]]
        }.max
      end

    # Q-learning 更新
    @stones[sa] =
      q + ALPHA * (reward + GAMMA * max_next_q - q)
    # p "in @stones[sa] = #{@stones[sa]}"
    # 下限ガード（探索死防止）
    @stones[sa] = 1 if @stones[sa] < 1
  end

  # =========================
  # 報酬付与
  # =========================
  def reward!(history, result)
    base_reward =
      case result
      when :win  then 3
      when :lose then -1
      else 0
      end

    history.each do |state, action|
      k = [key(state), action]
      @stones[k] += base_reward

      # 石ころは 1 未満にしない（探索の死を防ぐ）
      @stones[k] = 1 if @stones[k] < 1
    end
  end
  # def reward!(history, result)
  #   base_reward =
  #     case result
  #     when :win  then 3
  #     when :lose then -1
  #     else 0
  #     end

  #   history.each_with_index do |(state, action), i|
  #     k = [key(state), action]

  #     # 序盤ほど少し強く反映
  #     weight = 1.0 - (i.to_f / history.size) * 0.5
  #     @stones[k] += base_reward * weight

  #     @stones[k] = 1 if @stones[k] < 1
  #   end
  # end

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
