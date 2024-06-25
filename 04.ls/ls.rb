# frozen_string_literal: true

require 'optparse'

def parse_options
  opt = OptionParser.new
  options = {}
  opt.on('-a') { options[:a] = true }
  opt.parse!(ARGV)
  options
end

def load_filenames(options)
  flags = options[:a] ? File::FNM_DOTMATCH : 0
  Dir.glob('*', flags)
end

def display_filename_matrix(file, column)
  file << '' if file.empty?
  surplus = file.size % column
  (column - surplus).times { file.push('') } unless surplus.zero?
  columnar_file_list = file.each_slice(file.size / column).to_a.transpose
  max_widths = columnar_file_list.flatten.map(&:size).max + 8
  columnar_file_list.each do |one_column_display|
    one_column_display.each do |column_item|
      print column_item.ljust(max_widths)
    end
    puts
  end
end

options = parse_options
filename_matrix = load_filenames(options)
display_filename_matrix(filename_matrix, 3)
