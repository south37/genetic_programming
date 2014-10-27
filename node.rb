module GeneticProgramming
  class Node
    def display(indent = 0)
      print "\s" * indent
    end
  end

  class ParamLeaf < Node
    def initialize(index)
      @index = index
    end

    def eval(*params)
      params[@index]
    end

    def display(indent = 0)
      super(indent)
      print "param#{@index}\n"
    end
  end

  class ConstLeaf < Node
    def initialize(const)
      @const = const
    end

    def eval(*params)
      @const
    end

    def display(indent = 0)
      super(indent)
      print "#{@const}\n"
    end
  end

  class EvalNode < Node
    def initialize(func_wrapper, *children)
      @func_wrapper = func_wrapper
      @children     = children
    end

    def initialize_copy(obj)
      @children     = obj.children.map { |child| child.dup }
    end

    attr_accessor :children

    def eval(*params)
      results = @children.map { |e| e.eval(*params) }
      @func_wrapper.call(*results)
    end

    def display(indent = 0)
      super(indent)
      print "#{name}\n"
      @children.each { |child| child.display(indent + 1) }
    end

    def name
      @func_wrapper.class.method_defined?(:name) ? @func_wrapper.name : 'no name'
    end
  end
end

if __FILE__ == $0
  require_relative './func_list'

  tree = EvalNode.new(FuncList[:add], ConstLeaf.new(1), ConstLeaf.new(2))
  p tree.eval
  tree.display
end

