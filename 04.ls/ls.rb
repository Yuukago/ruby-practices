# frozen_string_literal: true

def load_filenames_into_matrix(column)
  files = Dir.glob('*')
  surplus = files.size % column
  (column - surplus).times { files.push('') } unless surplus.zero?
  files.each_slice(files.size / column).to_a.transpose
end

def display_filename_matrix(file)
  max_widths = file.flatten.map(&:size).max + 8
  file.each do |one_column_display|
    one_column_display.each do |column_item|
      print column_item.ljust(max_widths)
    end
    puts
  end
end

filename_matrix = load_filenames_into_matrix(3)
display_filename_matrix(filename_matrix)
