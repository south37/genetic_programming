require_relative './solve'

class TestSet
  def initialize(hidden_proc)
    @hidden_proc = hidden_proc
    @test_set    = build_test_set
  end

  def build_test_set
    [*0..200].map do |i|
      x = rand(40)
      y = rand(40)
      [x, y, @hidden_proc.call(x, y)]
    end
  end

  def get_score(tree)
    @test_set.map { |x, y, test_value|
      (tree.eval(x, y) - test_value).abs
    }.reduce(:+)
  end
end

if __FILE__ == $0
  test_set = TestSet.new(lambda { |x, y| x ** 2 + 3 * y })
  GeneticProgramming::Solver.new(test_set).evolve(2, 500)
end

