require_relative './func_list'
require_relative './node'

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
      population = Array.new(pop_size) { GeneticProgramming.make_random_tree(@score_obj.param_size) }
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
            population[i] = GeneticProgramming.mutate(
              GeneticProgramming.crossover(tree1, tree2, @crossover_rate),
              @score_obj.param_size, @mutate_rate
            )
          else
            population[i] = GeneticProgramming.make_random_tree(@score_obj.param_size)
          end
        end
      end
      tree_with_score.first[:tree].display
      tree_with_score.first[:tree]
    end
  end

  def self.make_random_tree(param_size, max_depth = 4, f_prob = 0.5, p_prob = 0.6)
    if rand < f_prob && max_depth > 0
      func   = FuncList::All.values.sample
      childs = Array.new(func.arity) { |i| make_random_tree(param_size, max_depth - 1, f_prob, p_prob) }
      EvalNode.new(func, *childs)
    elsif rand < p_prob
      ParamLeaf.new(rand(param_size))
    else
      ConstLeaf.new(rand(10))
    end
  end

  def self.mutate(tree, param_size, change_prob = 0.1)
    if rand < change_prob
      make_random_tree(param_size)
    else
      result = tree.dup
      if tree.class.method_defined?(:children)
        result.children = tree.children.map { |child| mutate(child, param_size, change_prob) }
      end
      result
    end
  end

  def self.crossover(tree1, tree2, swap_prob = 0.7, top = true)
    if rand < swap_prob && !top
      tree2.dup
    else
      result = tree1.dup
      if tree1.class.method_defined?(:children) && tree2.class.method_defined?(:children)
        result.children = tree1.children.map { |child| crossover(child, tree2.children.sample, swap_prob, false) }
      end
      result
    end
  end
end

