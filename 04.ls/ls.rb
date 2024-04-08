# frozen_string_literal: true

def file_list(column)
  files = Dir.glob('*').sort
  surplus = files.size % column
  if surplus == 1
    files.push('', '')
  elsif surplus == 2
    files.push('')
  end
  files.each_slice(files.size / column).to_a.transpose
end

def display_files(file)
  file.each do |array|
    array.each do |element|
      print element.ljust(24)
    end
    print "\n"
  end
end

split_arrays = file_list(3)
display_files(split_arrays)
