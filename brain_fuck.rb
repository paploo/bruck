# TODO:
# + Make the debug print the tape with the head position integrated into it.
# + Make the debug print only show the tape for no more than 8 entries on each side of the head.
# + Make the debug mode complete with breakpoints, stepping, and inspection command entry.
# + Make the token number's width in debug output be determined via the ceiling of the log10 of the program length.
class BrainFuck
  
  def initialize(program, opts={})
    opts = {:cells => 30000, :debug => true}.merge(opts)
    
    @program = program
    @cells = opts[:cells]
    @tape = Array.new(@cells,0)
    @head_position = 0
    @byte_code = nil
    @program_position = 0
    @debug = opts[:debug]
    @output_buffer = []
  end
  
  attr_reader :tape
  
  def compile
    valid_token_bytes = ['<', '>', '+', '-', ',', '.', '[', ']'].map {|c| c.ord} # Really, I should do a self.methods, and look at the execute methods.
    @byte_code = @program.bytes.to_a.select {|b| valid_token_bytes.include?(b) }
  end
  
  def debug_string(executed_byte_token)
    program_pos = "%0#{Math.log10(@byte_code.length).ceil}d" % @program_position
    head_pos = "%0#{Math.log10(@cells).ceil}d" % @head_position
    tape_text = tape.hilight_position(@head_position)
    return "#{executed_byte_token.chr} #{program_pos} - #{@head_position} #{tape_text} --> #{@output_buffer.inspect}"
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

class Array
  
  def hilight_position(index, width=8)
    min_index = [index-width, 0].max
    max_index = [index+width, self.length-1].min
    
    buf = []
    buf += self[min_index..index-1] if index > 0
    buf << '<' + self[index].to_s + '>' unless index < 0 || index >= self.length
    buf += self[index+1..max_index] if index < self.length
    return min_index.to_s + ':[' + buf.map {|x| x.to_s.rjust(1)}.join(", ") + ']:' + max_index.to_s
  end
  
end

if( $0 == __FILE__ )
  # Idea: since we can seek to a prev zero or a next zero, we can use those as markers with the value after it being the meaningful value.
  # We'd have to start by changing a bunch of values to 1 first.
  
  prog = "input:+++++ clear:>[-]>[-]<< copy:[->+>+<<]>>[-<<+>>]<<" # This copies the value in cell 0 into cell 1, using cell 2 as a register, and leaves the head at cell 0.
  #prog = "input1:++++ input2:+++ copy0to2:"
  #prog = "+>++>+++>++++<<<[>]"
  bf = BrainFuck.new(prog, :cells => 8)
  bf.run
end
