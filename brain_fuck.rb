class BrainFuck
  
  def initialize(program, cells=30000)
    @program = program
    @cells = cells
    @tape = Array.new(@cells,0)
    @head_position = 0
    @byte_code = []
    @program_position = 0
    @debug = true
    @output_buffer = []
  end
  
  def compile
    valid_token_bytes = ['<', '>', '+', '-', ',', '.', '[', ']'].map {|c| c.ord} # Really, I should do a self.methods, and look at the execute methods.
    @byte_code = @program.bytes.to_a.select {|b| valid_token_bytes.include?(b) }
  end
  
  def run
    while( current_byte_token  )
      m = "execute_#{current_byte_token}".to_sym
      STDERR.puts "#{current_byte_token.chr}:#{@program_position}:#{@byte_code.inspect} - #{@head_position}:#{@tape.inspect} --> #{@output_buffer.inspect}" if @debug
      self.send(m) if self.private_methods.include?(m)
      @program_position += 1
    end
    return @output_buffer
  end
  
  private
  
  def current_byte_token
    @byte_code[@program_position]
  end
  
  
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
    STDOUT.puts get()
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
    if( get.zero? )
      while(current_byte_token != ']'.ord)
        @program_position += 1
      end
    end
  end
  
  # ]
  # }
  def execute_93
    while(current_byte_token != '['.ord)
     puts current_byte_token.chr.inspect
     @program_position -= 1
    end
    @program_position -= 1
  end
  
end

bf = BrainFuck.new("++++[.--]>+.", 10)
bf.compile
puts bf.inspect
bf.run
puts bf.inspect