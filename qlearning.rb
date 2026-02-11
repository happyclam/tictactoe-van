# qlearning.rb

require "pathname"
require_relative "./disappearing_markov"
require_relative "./qlearning_agent"

# game = DisappearingTicTacToe.new
game = DisappearingMarkov.new
agent = QLearningAgent.new

EPISODES = 1_000_000

EPISODES.times do |ep|
  game.reset

  until game.over?
    state = game.state
    actions = game.legal_actions
    epsilon = [0.1, 1.0 - ep / 1_000_000.0].max
    action = agent.choose_action(state, actions, epsilon)
    game.play(action)
    reward =
      case game.result
      when :win then 3
      when :lose then -1
      # step penalty
      else -0.01
      end
    # p "game.result = #{game.result}"
    next_state   = game.state
    next_actions = game.legal_actions
    agent.learn!(state, action, reward, next_state, next_actions)
  end
end

puts "学習完了"

p agent.stones.length
p agent.stones
QLearningAgent::save("./q_agent.dump", agent)
