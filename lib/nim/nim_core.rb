module Nim
  class Nim

    #游戏规则：分成几摊的豆子，两个玩家轮流拣，一次可拿任意一摊里的至少一颗，拣掉最后一粒豆子的玩家判负。
    
    def initialize
      puts %q{
You and Q take turns nim beans from distinct heaps, 
On each turn, you must nim at least one bean, and may nim any number of beans provided they all come from the same heap.

Whom nim the last one bean were *lost*

}

      a = [1,3,5,7]
      b = [3,4,5,6]
      puts "heap 1 (#{a.inject{|x, sum| x + sum}} beans)"
      draw0(a)
      puts "heap 2 (#{b.inject{|x, sum| x + sum}} beans)"
      draw0(b)
      
      loop do
        print 'choose the heap 1/2: '
        heap = gets.to_i
        if [1,2].include?(heap)
          @mat = heap == 1 ? a : b
          break 
        end
        puts %q{    input: 1 or 2
}
      end
      
      init_unsafe_positions
      
      hand = 1
      
      loop do
        print 'nim first or second 1/2: '
        g = gets
        if g.strip == "unsafe"
          @unsafe_positions.each{|x| puts x.join ' '}
          draw_mat
        else
          hand = g.to_i
          break if [1,2].include?(hand)
          puts %q{    input: 1 or 2
}
        end
      end
      puts 
      
      ai_pick if hand == 2
      
      loop do
      
        loop do
          print 'you nim: '
          args = gets.split ' '
          
          if args.size == 1
            iarg0 = args[0].to_i
            
            if iarg0 > 0 and iarg0 < 10 #4
              pos = iarg0 - 1
              if (0...@mat.size).include?(pos) and @mat[pos] > 0
                pick(pos)
                break
              end
            elsif iarg0 > 10 and iarg0 < 100  #45
              pos = iarg0 / 10 - 1
              num = iarg0 % 10
              if (0...@mat.size).include?(pos) and num > 0 and @mat[pos] >= num
                pick(pos, num)
                break
              end
            end
            
          elsif args.size == 2
            iarg0 = args[0].to_i
            iarg1 = args[1].to_i
            
            if iarg0 > 0 and iarg0 < 10 and iarg1 > 0 and iarg1 < 10  #4 5
              pos = iarg0 -1
              num = iarg1
              if (0...@mat.size).include?(pos) and @mat[pos] >= num
                pick(pos, num)
                break
              end
            end
          end
          puts %q{    invalid inputs.
    nim least 1 beans from a line.
    nim 5 beans from line 4, inputs: 45 or 4 5
    nim all beans from line 4, inputs: 4
}
        end
        
        if @mat == [0,0,0,0]
          puts 'you *LOSE* :('
          break
        end
        
        ai_pick
        if @mat == [0,0,0,0]
          puts 'you *WIN* :)'
          break
        end
      end
      
    end
    
    
    def ai_pick
      #行动集
      actions = Hash.new

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
          actions[scoped_index] = scoped_value - dup.shift
        end
      end
      
      #拣取的下标和数量
      pos = num = 0
      
      if actions.size > 0
        #随机挑一个候选执行
        keys = actions.keys
        pos = keys[Random.new.rand(0...keys.size)]
        num = actions[pos]
      else
        #值不为0的下标集
        pos_ex = []
        @mat.each_with_index do |x, i|
          pos_ex << i if x > 0
        end
        
        #从不为0的堆中随机找一堆，随机拣取n颗
        pos = pos_ex[Random.new.rand(0...pos_ex.size)]
        num = Random.new.rand(1..@mat[pos])
      end

      puts "Q nim: #{(pos + 1) * 10 + num}"
      pick(pos, num)
    end
    
    
    def pick(pos, num=@mat[pos])
      @mat[pos] -= num
      puts
      draw_mat
    end
    
    
    def draw_mat
      draw(@mat)
    end
    
    
    def draw(mat)
      graph = ''
      space = ' '
      dot = '.'
      
      mat.each_with_index do |c, i|
        graph << "#{space * 4} #{i + 1} #{space * (3 - i)} #{(dot + space) * c} \n"
      end
      
      puts "#{graph}\n"
    end
    
    
    def draw0(mat)
      graph = ''
      space = ' '
      dot = '.'
      
      mat.each_with_index do |c, i|
        graph << "#{space * 4} #{space * (3 - i)} #{(dot + space) * c} \n"
      end
      
      puts "#{graph}\n"
    end
    
    
    def init_unsafe_positions
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
      
      puts
      draw_mat
    end
    
    def gets
      STDIN.gets
    end
    
  end
end
