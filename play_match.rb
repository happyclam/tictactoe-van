# play_match.rb

require "pathname"
require_relative "./disappearing_markov"
require_relative "./qlearning_agent"
require_relative "./stone_agent"
require_relative "./alpha-beta"

q_agent  = QLearningAgent.read("q_agent.dump")
mc_agent = StoneAgent.read("mc_agent.dump")

def play_match(q_agent, mc_agent, games = 1_000)
  # ↓---αβ法と対戦するときに必要-----------------
  ab = AlphaBeta.new  #αβ法を使ったプログラムとの対戦
  # ↑-------------------------------
  stats = { q_win: 0, mc_win: 0, draw: 0 }

  games.times do |i|
    game = DisappearingMarkov.new
  # ↓---αβ法と対戦するときに必要-----------------
    ab.board.init
  # ↑-------------------------------
    state = game.state
    current = :q
    p "Start! count: #{i + 1}"
    move_count = 0
    until game.over?
      p "=========================="
      legal = game.legal_actions
      action =
        if current == :q
          # q_agent.choose_action_greedy(state, legal)
          # mc_agent.choose_action_greedy(state, legal)
          ab.choose_action(state)
        else
          # mc_agent.choose_action_greedy(state, legal)
          q_agent.choose_action_greedy(state, legal)
          # ab.choose_action(state)
          # mc_agent.choose_action(state, legal)
        end
      game.play(action)
      state = game.state
      current = (current == :q ? :mc : :q)
      game.display
      move_count += 1
      exit if move_count > 50
    end

    if current == :q
      stats[:mc_win] += 1
      p "mc_win"
    elsif current == :mc
      stats[:q_win] += 1
      p "q_win"
    else
      stats[:draw] += 1
    end
  end

  stats
end

p play_match(q_agent, mc_agent, 100)

