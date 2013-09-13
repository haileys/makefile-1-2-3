def num_to_alpha(n)
  letters = ""
  n -= 1
  begin
    letters << [*"A".."Z"][n % 26]
    n /= 26
  end until n.zero?
  letters.reverse
end

rows = File.readlines(ARGV.first).map { |line| line.chomp.split(/\s+/) }

row_names = (1..Float::INFINITY)
col_names = (1..Float::INFINITY).lazy.map { |n| num_to_alpha(n) }

cells =  rows.zip(row_names).flat_map { |columns, row_name| columns.zip(col_names).map { |cell, col_name| ["#{col_name}#{row_name}", cell] } }

File.open("Makefile", "w") do |f|
  f << "all: #{cells.map(&:first).join(" ")}\n\n"

  f << ".PHONY: clean\n"
  f << "clean:\n\trm -f #{cells.map(&:first).join(" ")}\n\n"

  f << "Makefile: #{ARGV.first} compiler.rb\n\truby compiler.rb #{ARGV.first}\n\n"

  cells.each do |pos, value|
    if value[0] == "="
      dependencies = []
      value = value[1..-1].gsub(/([A-Z]+[0-9]+)/) {
        dependencies << $1
        "$(shell cat #{$1})"
      }
      f << "#{pos}: Makefile #{dependencies.join(" ")}\n\techo \"#{value}\" | bc > #{pos}\n\n"
    else
      f << "#{pos}: Makefile\n\techo #{value} > #{pos}\n\n"
    end
  end
end
