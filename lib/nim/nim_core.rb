module Nim
  class Nim
    #游戏规则：分别为3，4，5，6颗的四摊豆子，两个玩家定下先后手，轮流拣，一次可拿任意一摊里的至少一颗，拣掉最后一粒豆子的玩家判负。 
    
    def initialize(hand = 2)
      init_mat_and_unsafe_positions
      
      @unsafe_positions.each do |x|
        puts x.join ' '
      end
      
      ai_pick if hand == 2
      while true
        print 'you nim:'
        man_pick STDIN.gets
        if @mat == [0,0,0,0]
          puts 'you lose.'
          break
        end
        
        ai_pick
        if @mat == [0,0,0,0]
          puts 'you win.'
          break
        end
      end
      
    end
   
    def draw_mat
      @graph = ''
      space = ' '
      dot = '.'
      
      @mat.each_with_index do |c, i|
        @graph << "#{space * 4} #{space * (3 - i)} #{(dot + space) * c} \n"
      end
      
      puts @graph
    end
    
    def man_pick(arg)
      intarg = arg.to_i
      @mat[intarg/10 - 1] -= intarg%10
      draw_mat
    end
    
    def ai_pick
      #下标和差额
      pos = diff = 0
      #排序的当前阵用于和@unsafe_positions比较
      sorted_mat = @mat.sort
      
      sorted_mat_ex = sorted_mat - [0]
      is_safe = false
      scoped_index = 0
      scoped_value = 0
      scoped_diff = 0
      #todo: 候选{}
      
      @unsafe_positions.each do |unsafe|
        unsafe_ex = unsafe - [0]
        not_equal = 0
        @mat.each_with_index do |x, i|
          if x != 0
            idx = unsafe_ex.index(x)
            if idx
              unsafe_ex.delete_at(idx)
            else
              #记下不相等的value和它的下标
              scoped_index = i
              scoped_value = x
              not_equal += 1
            end
          end
        end
        #有一堆豆子数不相等 => 可以拿成unsafe => 是安全的
        if not_equal == 1
          is_safe = true
          scoped_diff = unsafe_ex.size == 1 ? scoped_value - unsafe_ex.shift : scoped_value
          break
        end
      end
      
      if is_safe
        #随机挑一个候选执行
        @mat[scoped_index] -= scoped_diff
      else
        puts 'r'
        #随机找下标和差额
        pos = Random.new.rand(0...@mat.size)
        diff = Random.new.rand(1..@mat[pos])
        
        @mat[pos] -= diff
      end
      
      puts "Q nim: #{(pos + 1) * 10 + diff}"
      draw_mat
    end
    
    def init_mat_and_unsafe_positions
      @mat = [3, 4, 5, 6]
      @unsafe_positions = []
      #初始化阵集
      arr = [] 
      for a in 0..@mat[0]
        for b in a..@mat[1]
          for c in b..@mat[2]
            for d in c..@mat[3]
              arr << [a, b, c, d]
            end
          end
        end
      end
      
      #remove [0,0,0,0]
      arr.shift 
      
      #first unsafe-position is [0,0,0,1]
      @unsafe_positions << arr.shift 
      
      #从小到大遍历阵集，增加unsafe
      arr.each do |sample|
        sample_ex = sample - [0]
        is_safe = false
        
        @unsafe_positions.each do |unsafe|
          unsafe_ex = unsafe - [0]
          not_equal = 0
          sample_ex.each do |x|
            idx = unsafe_ex.index(x)
            idx ? unsafe_ex.delete_at(idx) : not_equal += 1  
          end
          #有一堆豆子数不一样 => 可以拿成一种unsafe => 是安全的
          if not_equal == 1
            is_safe = true
            break
          end
        end
        
        @unsafe_positions << sample unless is_safe
      end
      
      draw_mat
    end
    
    attr_reader :mat, :graph, :unsafe_positions
  end
end
