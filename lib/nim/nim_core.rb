module Nim
  class Nim
    #��Ϸ���򣺷ֱ�Ϊ3��4��5��6�ŵ���̯���ӣ�������Ҷ����Ⱥ��֣�������һ�ο�������һ̯�������һ�ţ�������һ�����ӵ�����и��� 
    
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
      #�±�Ͳ��
      pos = diff = 0
      #����ĵ�ǰ�����ں�@unsafe_positions�Ƚ�
      sorted_mat = @mat.sort
      
      sorted_mat_ex = sorted_mat - [0]
      is_safe = false
      scoped_index = 0
      scoped_value = 0
      scoped_diff = 0
      #todo: ��ѡ{}
      
      @unsafe_positions.each do |unsafe|
        unsafe_ex = unsafe - [0]
        not_equal = 0
        @mat.each_with_index do |x, i|
          if x != 0
            idx = unsafe_ex.index(x)
            if idx
              unsafe_ex.delete_at(idx)
            else
              #���²���ȵ�value�������±�
              scoped_index = i
              scoped_value = x
              not_equal += 1
            end
          end
        end
        #��һ�Ѷ���������� => �����ó�unsafe => �ǰ�ȫ��
        if not_equal == 1
          is_safe = true
          scoped_diff = unsafe_ex.size == 1 ? scoped_value - unsafe_ex.shift : scoped_value
          break
        end
      end
      
      if is_safe
        #�����һ����ѡִ��
        @mat[scoped_index] -= scoped_diff
      else
        puts 'r'
        #������±�Ͳ��
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
      #��ʼ����
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
      
      #��С��������󼯣�����unsafe
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
          #��һ�Ѷ�������һ�� => �����ó�һ��unsafe => �ǰ�ȫ��
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
