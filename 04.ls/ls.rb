# frozen_string_literal: true

def file_list(column)
  files = Dir.glob('*')
  surplus = files.size % column
  (column - surplus).times { files.push('') } unless surplus.zero?
  files.each_slice(files.size / column).to_a.transpose
end

def display_files(file)
  max_widths = file.flatten.map(&:size).max + 8

  file.each do |array|
    array.each do |element|
      print element.ljust(max_widths)
    end
    puts
  end
end

split_arrays = file_list(3)
display_files(split_arrays)
