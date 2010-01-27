class BrainFuck
  
  def initialize(program, cells=30000)
    @program = program
    @cells = cells
    @tape = Array.new(@cells,0)
    @head_position = 0
    @debug = true
    @output_buffer = []
    @current_token = nil
  end
  
  def run
    @program.each_byte do |byte|
      @current_token = byte.chr
      m = "execute_#{byte}".to_sym
      self.send(m) if self.private_methods.include?(m)
      STDERR.puts byte.chr + " - " + @head_position.to_s + ':' + @tape.inspect + " --> " + @output_buffer.inspect if @debug
    end
  end
  
  private
  
  def advance
    @head_position += 1
    raise IndexError, "Head ran off right side of tape" if @head_position >= @cells
  end
  
  def retard
    @head_position -= 1
    raise IndexError, "Head ran off left side of tape" if @head_position < 0
  end
  
  def get
    @tape[@head_position]
  end
  
  def set(v)
    @tape[@head_position] = v.to_i
  end
  
  def incr
    @tape[@head_position] += 1
  end
  
  def decr
    @tape[@head_position] -= 1
  end
  
  # >
  # ++p
  def execute_62
    advance()
  end
  
  # <
  # --p
  def execute_60
    retard()
  end
  
  # +
  # ++*p
  def execute_43
    incr()
  end
  
  # -
  # --*p
  def execute_45
    decr()
  end
  
  # .
  # putchar(*p)
  def execute_46
    @output_buffer << get()
    STDOUT.puts value
  end
  
  # ,
  # *p = getchar()
  def execute_44
    STDERR << "\nInput Number: \n"
    set( (STDIN.gets||'').chomp.to_i )
  end
  
  # [
  # while(*p){
  def execute_91
    # If the value is zero, we have to fast-forward parsing to
    # the next end.  If it is non-zero, we don' have to do anything.
  end
  
  # ]
  # }
  def execute_93
    # Move to the beginning of the last loop.
  end
  
end

bf = BrainFuck.new("+++[.-]>+.", 10)
puts bf.inspect
bf.run
puts bf.inspect