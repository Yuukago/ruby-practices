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
PERMISSION_CODES = {
  '7' => 'rwx',
  '6' => 'rw-',
  '5' => 'r-x',
  '4' => 'r--',
  '3' => '-wx',
  '2' => '-w-',
  '1' => '--x',
  '0' => '---'
}.freeze

FILE_TYPE = {
  'file' => '-',
  'directory' => 'd',
  'characterSpecial' => 'c',
  'blockSpecial' => 'b',
  'fifo' => 'p',
  'link' => 'l',
  'socket' => 's',
  'unknown' => '?'
}.freeze

def permission_and_filetype(file_detail_information)
  permission = file_detail_information.mode.to_s(8).slice(-3..-1).chars
  FILE_TYPE[file_detail_information.ftype] + permission.map { |n| PERMISSION_CODES[n] }.join
end

def last_updated(file_detail_information)
  last_updated = file_detail_information.mtime
  half_year_ago = Date.today << 6
  time_or_year = last_updated.to_date >= half_year_ago ? last_updated.strftime('%H:%M') : last_updated.year.to_s.rjust(5)
  "#{last_updated.mon.to_s.rjust(2)} #{last_updated.day.to_s.rjust(2)} #{time_or_year}"
end

def collect_file_details(file_detail_information)
  file_detail_information.map do |file|
    file_stat = File.lstat(file)
    {
      permission: permission_and_filetype(file_stat),
      nlink: file_stat.nlink.to_s,
      username: Etc.getpwuid(file_stat.uid).name,
      groupname: Etc.getgrgid(file_stat.gid).name,
      filesize: file_stat.size.to_s,
      time: last_updated(file_stat),
      filename: file
    }
  end
end

def list_file_details(files_in_the_directory)
  total_blocks = files_in_the_directory.sum { |file| File::Stat.new(file).blocks }
  puts "total #{total_blocks}"
  collect_file_details = collect_file_details(files_in_the_directory)
  max_width = {
    nlink: collect_file_details.map { |file_information| file_information[:nlink].size }.max,
    username: collect_file_details.map { |file_information| file_information[:username].size }.max,
    groupname: collect_file_details.map { |file_information| file_information[:groupname].size }.max,
    filesize: collect_file_details.map { |file_information| file_information[:filesize].size }.max
  }
  collect_file_details.each do |file|
    puts [
      file[:permission],
      file[:nlink].rjust(max_width[:nlink]),
      file[:username].rjust(max_width[:username]),
      file[:groupname].rjust(max_width[:groupname]),
      file[:filesize].rjust(max_width[:filesize]),
      file[:time],
      file[:filename]
    ].join('  ')
  end
end

options = parse_options
filename_matrix = load_filenames(options)
options[:l] ? list_file_details(filename_matrix) : display_filename_matrix(filename_matrix, 3)
