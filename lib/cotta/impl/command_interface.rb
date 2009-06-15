module Cotta
  # A command line interface tha can
  # be stubbed out by InMemorySystem
  class CommandInterface
    def initialize(io = SystemIo.new)
      @io = io
    end

    def puts(content)
      @io.puts(content)
    end

    def prompt(question)
      puts(question)
      gets
    end

    def prompt_for_choice(question, candidates)
      puts(question)
      0.upto(candidates.size - 1) do |index|
        puts "[#{index + 1}] #{candidates[index]}"
      end
      answer = gets.to_i
      seletion = nil
      if answer > 0 && answer <= candidates.size
        selection = candidates[answer - 1]
      end
      return selection
    end

    def gets
      @io.gets
    end

  end

  class SystemIo
    def puts(content)
      $stdout.puts(content)
    end

    def gets
      $stdin.gets
    end
  end
end