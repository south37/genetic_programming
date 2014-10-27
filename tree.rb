module GeneticProgramming
  module Tree
    class Node
      def display(indent = 0)
        print "\s" * indent
      end

      def have_children?
        false
      end

      def mutate(param_size, change_prob = 0.1)
        if rand < change_prob
          Tree.make_random_tree(param_size)
        else
          result = self.dup
          if self.have_children?
            result.children = self.children.map do |child|
              child.mutate(param_size, change_prob)
            end
          end
          result
        end
      end

      def crossover(other, swap_prob = 0.7, top = true)
        if rand < swap_prob && !top
          other.dup
        else
          result = self.dup
          if self.have_children? && other.have_children?
            result.children = self.children.map do |child|
              child.crossover(other.children.sample, swap_prob, false)
            end
          end
          result
        end
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
        EvalNode.new(func, *childs)
      elsif rand < p_prob
        ParamLeaf.new(rand(param_size))
      else
        ConstLeaf.new(rand(10))
      end
    end
  end
end

if __FILE__ == $0
  require_relative './func_list'

  module GeneticProgramming
    tree = Tree::EvalNode.new(
      FuncList[:add], Tree::ConstLeaf.new(1), Tree::ConstLeaf.new(2)
    )
    p tree.eval
    tree.display
  end
end

