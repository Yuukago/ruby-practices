# frozen_string_literal: true

require 'optparse'

def optional_hangar
  opt = OptionParser.new
  file_with_options = []
  opt.on('-a') { file_with_options = Dir.glob('*', File::FNM_DOTMATCH) }
  opt.parse!(ARGV)
  file_with_options
end

def load_filenames_into_matrix(column)
  files = if ARGV[0]&.match?(/^-./)
            optional_hangar
          else
            Dir.glob('*')
          end
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
