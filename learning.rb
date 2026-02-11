# learning.rb

require "pathname"
require_relative "./disappearing_tictactoe"
require_relative "./disappearing_markov"
require_relative "./stone_agent"

# game = DisappearingTicTacToe.new
game = DisappearingMarkov.new
agent = StoneAgent.new

EPISODES = 50_000_000

EPISODES.times do |ep|
  game.reset
  history = []
  until game.over?
    state = game.state
    actions = game.legal_actions
    epsilon = [0.05, 1.0 - ep.to_f / 50_000_000.0].max
    action = agent.choose_action(state, actions, epsilon)
    game.play(action)
    history << [state, action]
  end
  agent.reward!(history, game.result)
end

puts "学習完了"

p agent.stones.length
p agent.stones
StoneAgent::save("./mc_agent.dump", agent)
