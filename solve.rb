require_relative './func_list'
require_relative './tree'

module GeneticProgramming
  class Solver
    def initialize(score_obj, max_gen = 500, mutate_rate = 0.1, crossover_rate = 0.1, exp_prob = 0.7, new_prob = 0.5)
      @score_obj      = score_obj
      @max_gen        = max_gen
      @mutate_rate    = mutate_rate
      @crossover_rate = crossover_rate
      @exp_prob       = exp_prob
      @new_prob       = new_prob
    end

    def select_index
      Math.log(Math.log(rand) / Math.log(@exp_prob)).to_i
    end

    def evolve(pop_size)
      population = Array.new(pop_size) { Tree.make_random_tree(@score_obj.param_size) }
      tree_with_score = []
      @max_gen.times do |count|
        tree_with_score = population.map { |tree| {tree: tree, score: @score_obj.score(tree)} }
                                    .sort_by { |tws| tws[:score] }
        p tree_with_score.first[:score]
        break if tree_with_score.first[:score] == 0

        population[0] = tree_with_score[0][:tree]
        population[1] = tree_with_score[1][:tree]
        (2..pop_size).each do |i|
          if rand > @new_prob
            tree1 = tree_with_score[select_index][:tree]
            tree2 = tree_with_score[select_index][:tree]
            population[i] = tree1.crossover(tree2, @crossover_rate)
                                 .mutate(@score_obj.param_size, @mutate_rate)
          else
            population[i] = Tree.make_random_tree(@score_obj.param_size)
          end
        end
      end
      tree_with_score.first[:tree].display
      tree_with_score.first[:tree]
    end
  end
end

