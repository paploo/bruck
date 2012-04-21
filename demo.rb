require_relative 'lib/brain_fuck'

def run(desc, prog)
  puts "***** #{desc} *****"

  bf = BrainFuck.new(prog, :cells => 8, :debug => true)
  bf.run

  puts "***** END #{desc} *****"
  puts "\n"
end

# This copies the value in cell 0 into cell 1, using cell 2 as a register, and leaves the head at cell 0.
run('Copy', "input:+++++ clear:>[-]>[-]<< copy:[->+>+<<]>>[-<<+>>]<<")

# This adds the first two values, destroying the second and placing the sum in the first.
run('Add', "input:++++>+++ add:[-<+>]")
