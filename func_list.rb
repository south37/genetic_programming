module GeneticProgramming
  module FuncList
    class FuncWrapper
      def initialize(func_proc, name, arity = nil)
        @proc  = func_proc
        @name  = name
        @arity = arity || func_proc.arity
      end

      attr_reader :name, :arity

      def call(*args)
        @proc.call(*args)
      end
    end

    All = {
      add:     FuncWrapper.new(:+.to_proc, 'add', 2),
      sub:     FuncWrapper.new(:-.to_proc, 'sub', 2),
      mul:     FuncWrapper.new(:*.to_proc, 'mul', 2),
      if:      FuncWrapper.new(lambda { |pred, cons, alter| (pred > 0) ? cons : alter }, 'if', 3),
      greater: FuncWrapper.new(lambda { |left, right| (left > right) ? 1 : 0 }, '>', 2)
    }

    def self.[](method_name)
      All[method_name]
    end
  end
end

if __FILE__ == $0
  FuncList::All.each { |name, f| p f.name }
end

