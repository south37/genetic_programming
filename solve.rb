require_relative './func_list'
require_relative './node'

module GeneticProgramming
  class Solver
    def initialize(score_obj, max_gen = 500, mutate_rate = 0.1, crossover_rate = 0.1, p_exp = 0.7, p_new = 0.5)
      @score_obj      = score_obj
      @max_gen        = max_gen
      @mutate_rate    = mutate_rate
      @crossover_rate = crossover_rate
      @p_exp          = p_exp
      @p_new          = p_new
    end

    def select_index
      Math.log(Math.log(rand) / Math.log(@p_exp)).to_i
    end

    def evolve(param_size, pop_size)
      population = Array.new(pop_size) { |i| make_random_tree(param_size) }
      scores = []
      @max_gen.times do |count|
        scores = rank_func(population)
        p scores[0][0]
        break if scores[0][0] == 0

        population[0] = scores[0][1]
        population[1] = scores[1][1]
        (2..pop_size).each do |i|
          if rand > @p_new
            tree1 = scores[select_index][1]
            tree2 = scores[select_index][1]
            population[i] = mutate(crossover(tree1, tree2, @crossover_rate), param_size, @mutate_rate)
          else
            population[i] = make_random_tree(param_size)
          end
        end
      end
      scores[0][1].display
      scores[0][1]
    end

    def rank_func(population)
      population.map { |tree| [@score_obj.get_score(tree), tree] }.sort_by { |score, tree| score }
    end

    def make_random_tree(param_size, max_depth = 4, f_prob = 0.5, p_prob = 0.6)
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

    def mutate(tree, param_size, change_prob = 0.1)
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

    def crossover(tree1, tree2, swap_prob = 0.7, top = true)
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
end

