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
      if @unsafe_positions.include? sorted_mat
        puts 'r'
        #随机找下标和差额
        pos = Random.new.rand(0...@mat.size)
        diff = Random.new.rand(1..@mat[pos])
        @mat[pos] -= diff
      else
        @unsafe_positions.each do |unsafe|
          #匹配堆数
          match = 0
          #暂记和unsafe不相等的值
          scoped_value = 0
          sorted_mat.each_with_index do |x, i|
            if x == unsafe[i]
              match += 1 
            else
              scoped_value = x
              diff = x - unsafe[i]
            end
          end
          #可以拣成unsafe的场合
          if match == @mat.size - 1
            pos = @mat.index(scoped_value)
            @mat[pos] -= diff
            break
          end
        end
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

      #[0,0,0,0]抛弃
      arr.shift 
      
      #[0,0,0,1]是本规则下的原初unsafe-position，推入unsafe集。
      @unsafe_positions << arr.shift 
      
      #从小到大遍历阵集，增加unsafe
      arr.each do |sample|
        sample_ex = sample - [0]
        is_safe = false
        #last_unsafe_ex = @unsafe_positions.last - [0]
        @unsafe_positions.each do |unsafe|
          unsafe_ex = unsafe - [0]
          #i = 0
          not_equal = 0
          sample_ex.each do |x|
            if unsafe_ex.size == 0
              not_equal += 1 
            else
              if x == unsafe_ex.first
                unsafe_ex.shift
              else
                not_equal += 1  #按顺序判断不对
              end
            end
          end
          #有一堆豆子数不一样 => 可以拿成unsafe => 是安全的
          if not_equal == 1
            puts 
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
