# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'

def parse_options
  opt = OptionParser.new
  options = {}
  opt.on('-a') { options[:a] = true }
  opt.on('-r') { options[:r] = true }
  opt.on('-l') { options[:l] = true }
  opt.parse!(ARGV)
  options
end

def load_filenames(options)
  flags = options[:a] ? File::FNM_DOTMATCH : 0
  filenames = Dir.glob('*', flags)
  options[:r] ? filenames.reverse : filenames
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

# ここからlオプション
def permission_and_filetype(file_detail_information)
  filetype = file_detail_information.ftype == 'file' ? '-' : 'd'
  permission = file_detail_information.mode.to_s(8).slice(-3..-1).chars
  permission_codes = { '7' => 'rwx', '6' => 'rw-', '5' => 'r-x', '4' => 'r--', '3' => '-wx', '2' => '-w-', '1' => '--x', '0' => '---' }
  filetype + permission.map { |n| permission_codes[n] }.join
end

def l_option(files_in_the_directory)
  total_blocks = files_in_the_directory.sum { |file| File::Stat.new(file).blocks }
  puts "total #{total_blocks}"
  max_width = {
    nlink: files_in_the_directory.map { |file| File::Stat.new(file).nlink.to_s.size }.max,
    username: files_in_the_directory.map { |file| Etc.getpwuid(File::Stat.new(file).uid).name.size }.max,
    groupname: files_in_the_directory.map { |file| Etc.getgrgid(File::Stat.new(file).gid).name.size }.max,
    size: files_in_the_directory.map { |file| File::Stat.new(file).size.to_s.size }.max
  }
  files_in_the_directory.each do |file|
    file_detail_information = File::Stat.new(file)
    permissions_and_type = permission_and_filetype(file_detail_information)
    username = Etc.getpwuid(file_detail_information.uid).name.rjust(max_width[:username])
    groupname = Etc.getgrgid(file_detail_information.gid).name.rjust(max_width[:groupname])
    size = file_detail_information.size.to_s.rjust(max_width[:size])
    last_updated = file_detail_information.mtime
    half_year_ago = Date.today << 6
    time_or_year = last_updated.to_date >= half_year_ago ? last_updated.strftime('%H:%M') : last_updated.year.to_s.rjust(5)
    last_updateds = "#{last_updated.mon.to_s.rjust(2)} #{last_updated.day.to_s.rjust(2)} #{time_or_year}"

    puts "#{permissions_and_type}  #{file_detail_information.nlink} #{username}  #{groupname}  #{size} #{last_updateds} #{file}"
  end
end

options = parse_options
filename_matrix = load_filenames(options)
options[:l] ? l_option(filename_matrix) : display_filename_matrix(filename_matrix, 3)
