require_relative './solve'

class TestSet
  def initialize(hidden_proc)
    @hidden_proc = hidden_proc
    @test_set    = build_test_set
  end

  def param_size
    @hidden_proc.arity
  end

  def build_test_set
    [*0..200].map do |i|
      params = Array.new(param_size) { rand(40) }
      [params, @hidden_proc.call(*params)]
    end
  end

  def score(tree)
    @test_set.map { |params, test_value|
      (tree.eval(*params) - test_value).abs
    }.reduce(:+)
  end
end

if __FILE__ == $0
  test_set = TestSet.new(lambda { |x, y| x ** 2 + 3 * y })
  GeneticProgramming::Solver.new(test_set).evolve(500)
end

