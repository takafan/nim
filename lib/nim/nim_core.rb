module Nim
  class Nim

    #游戏规则：分别为3，4，5，6颗的四摊豆子，两个玩家定下先后手，轮流拣，一次可拿任意一摊里的至少一颗，拣掉最后一粒豆子的玩家判负。 
    
    def initialize(hand = 2)
      init_mat_and_unsafe_positions
      
      @unsafe_positions.each{|x| puts x.join ' '}
      
      ai_pick if hand == 2
      while true
        print 'You nim:'
        man_pick STDIN.gets
        if @mat == [0,0,0,0]
          puts 'You LOSE :('
          break
        end
        
        ai_pick
        if @mat == [0,0,0,0]
          puts 'You WIN :)'
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
      coll = Hash.new
      tmp = []
      @unsafe_positions.each do |unsafe|
        dup = unsafe.dup

        scoped_index = 0
        scoped_value = 0

        @mat.each_with_index do |x, i|
          idx = dup.index(x)
          if idx
            dup.delete_at(idx)
          else
            #暂记不相等的value和它的下标
            scoped_index = i
            scoped_value = x
          end
        end
        
        if dup.size == 1 and scoped_value > dup.first
          coll[scoped_index] = scoped_value - dup.shift
        end
      end
      
      #拣取的下标和数量
      pos = num = 0
      
      if coll.size > 0
        #随机挑一个候选执行
        keys = coll.keys
        pos = keys[Random.new.rand(0...keys.size)]
        num = coll[pos]
      else
        puts 'r'
        #随机找下标和差额
        pos = Random.new.rand(0...@mat.size)
        num = Random.new.rand(1..@mat[pos])
      end
      
      @mat[pos] -= num
      
      puts "Q nim: #{(pos + 1) * 10 + num}"
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
        is_safe = false
        
        @unsafe_positions.each do |unsafe|
        
          dup = unsafe.dup
          sample.each_with_index do |x, i|
            j = dup.index(x)
            dup.delete_at(j) if j
          end
          
          #有一堆豆子数不相等(多出) => 可以拿成一种unsafe => 是安全的
          if dup.size == 1
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
