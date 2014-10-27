module GeneticProgramming
  module Tree
    class Node
      def display(indent = 0)
        print "\s" * indent
      end

      def have_children?
        false
      end
    end

    class ParamLeaf < Node
      def initialize(index)
        @index = index
      end

      def display(indent = 0)
        super(indent)
        print "param#{@index}\n"
      end

      def eval(*params)
        params[@index]
      end
    end

    class ConstLeaf < Node
      def initialize(const)
        @const = const
      end

      def display(indent = 0)
        super(indent)
        print "#{@const}\n"
      end

      def eval(*params)
        @const
      end
    end

    class EvalNode < Node
      def initialize(func, *children)
        @func     = func
        @children = children
      end

      def initialize_copy(obj)
        @children = obj.children.map { |child| child.dup }
      end

      attr_accessor :children

      def display(indent = 0)
        super(indent)
        print "#{name}\n"
        @children.each { |child| child.display(indent + 1) }
      end

      def eval(*params)
        results = @children.map { |e| e.eval(*params) }
        @func.call(*results)
      end

      def have_children?
        true
      end

      def name
        @func.class.method_defined?(:name) ? @func.name : 'no name'
      end
    end

    def self.make_random_tree(param_size, max_depth = 4, f_prob = 0.5, p_prob = 0.6)
      if rand < f_prob && max_depth > 0
        func   = FuncList::All.values.sample
        childs = Array.new(func.arity) do
          make_random_tree(param_size, max_depth - 1, f_prob, p_prob)
        end
        self::EvalNode.new(func, *childs)
      elsif rand < p_prob
        self::ParamLeaf.new(rand(param_size))
      else
        self::ConstLeaf.new(rand(10))
      end
    end

    def self.mutate(tree, param_size, change_prob = 0.1)
      if rand < change_prob
        make_random_tree(param_size)
      else
        result = tree.dup
        if tree.have_children?
          result.children = tree.children.map do |child|
            mutate(child, param_size, change_prob)
          end
        end
        result
      end
    end

    def self.crossover(tree1, tree2, swap_prob = 0.7, top = true)
      if rand < swap_prob && !top
        tree2.dup
      else
        result = tree1.dup
        if tree1.have_children? && tree2.have_children?
          result.children = tree1.children.map do |child|
            crossover(child, tree2.children.sample, swap_prob, false)
          end
        end
        result
      end
    end
  end
end

if __FILE__ == $0
  require_relative './func_list'

  tree = EvalNode.new(FuncList[:add], ConstLeaf.new(1), ConstLeaf.new(2))
  p tree.eval
  tree.display
end

