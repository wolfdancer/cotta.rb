module Cotta
# Reads from the input stream to output stream
module IoChain
  def copy_io(input, output)
#    output.write input.read
    while (content = input.read(1024)) do
      output.write content
    end
  end
end
end