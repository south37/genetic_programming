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

      @tree_with_scores = []
    end

    def evolve(pop_size)
      population = Array.new(pop_size) { Tree.make_random_tree(@score_obj.param_size) }
      @max_gen.times do
        @tree_with_scores = population
          .map { |tree| {tree: tree, score: @score_obj.score(tree)} }
          .sort_by { |tws| tws[:score] }
        p @tree_with_scores.first[:score]
        break if @tree_with_scores.first[:score] == 0

        population[0] = @tree_with_scores[0][:tree]
        population[1] = @tree_with_scores[1][:tree]
        (2..pop_size).each do |i|
          if rand > @new_prob
            population[i] = select_tree
              .crossover(select_tree, @crossover_rate)
              .mutate(@score_obj.param_size, @mutate_rate)
          else
            population[i] = Tree.make_random_tree(@score_obj.param_size)
          end
        end
      end
      @tree_with_scores.first[:tree].display
      @tree_with_scores.first[:tree]
    end

    def select_index
      Math.log(Math.log(rand) / Math.log(@exp_prob)).to_i
    end

    def select_tree
      @tree_with_scores[select_index][:tree]
    end
  end
end

