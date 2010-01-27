class BrainFuck
  
  def initialize(program, cells=30000)
    @program = program
    @cells = cells
    @tape = Array.new(@cells,0)
    @head_position = 0
    @byte_code = nil
    @program_position = 0
    @debug = true
    @output_buffer = []
  end
  
  def compile
    valid_token_bytes = ['<', '>', '+', '-', ',', '.', '[', ']'].map {|c| c.ord} # Really, I should do a self.methods, and look at the execute methods.
    @byte_code = @program.bytes.to_a.select {|b| valid_token_bytes.include?(b) }
  end
  
  def debug_string(executed_byte_token)
    #return "#{current_token}:#{@program_position}:#{@byte_code.inspect} - #{@head_position}:#{@tape.inspect} --> #{@output_buffer.inspect}"
    return "#{executed_byte_token.chr} @ #{@program_position} - #{@head_position}:#{@tape.inspect} --> #{@output_buffer.inspect}"
  end
  
  def run
    compile if @byte_code.nil?
    while( executed_byte_token = current_byte_token  )
      m = "execute_#{executed_byte_token = current_byte_token}".to_sym
      #STDERR.puts debug_string(executed_byte_token) if @debug
      self.send(m) if self.private_methods.include?(m)
      STDERR.puts debug_string(executed_byte_token) if @debug
    end
    return @output_buffer
  end
  
  private
  
  # ---------- Program Helpers ----------
  def current_byte_token
    @byte_code[@program_position]
  end
  
  def current_token
    return current_byte_token.chr
  end
  
  def advance_token
    @program_position +=1
  end
  
  def retard_token
    @program_position -=1
    raise IndexError, "Cannot move to a token before the first in the program." if @program_position < 0
  end
  
  def advance_to_next_byte_token(byte_token)
    while(current_byte_token != byte_token)
      advance_token
    end
  end
  
  def retard_to_prev_byte_token(byte_token)
    while(current_byte_token != byte_token)
      retard_token
    end
  end
  
  # ---------- Read Head Helpers ----------
  
  def advance_head
    @head_position += 1
    raise IndexError, "Head ran off right side of tape" if @head_position >= @cells
  end
  
  def retard_head
    @head_position -= 1
    raise IndexError, "Head ran off left side of tape" if @head_position < 0
  end
  
  def get_value
    @tape[@head_position]
  end
  
  def set_value(v)
    @tape[@head_position] = v.to_i
  end
  
  def incr_value
    @tape[@head_position] += 1
  end
  
  def decr_value
    @tape[@head_position] -= 1
  end
  
  # >
  # ++p
  def execute_62
    advance_head()
    advance_token()
  end
  
  # <
  # --p
  def execute_60
    retard_head()
    advance_token()
  end
  
  # +
  # ++*p
  def execute_43
    incr_value()
    advance_token()
  end
  
  # -
  # --*p
  def execute_45
    decr_value()
    advance_token()
  end
  
  # .
  # putchar(*p)
  def execute_46
    @output_buffer << get_value()
    STDOUT.puts get_value()
    advance_token()
  end
  
  # ,
  # *p = getchar()
  def execute_44
    STDERR << "\nInput Number: \n"
    set_value( (STDIN.gets||'').chomp.to_i )
    advance_token()
  end
  
  # [
  # while(*p){
  def execute_91
    advance_to_next_byte_token(']'.ord) if get_value.zero?
    advance_token()
  end
  
  # ]
  # }
  def execute_93
   retard_to_prev_byte_token('['.ord)
  end
  
end

bf = BrainFuck.new("++++[.--]>+.", 10)
puts bf.inspect
bf.run
puts bf.inspect