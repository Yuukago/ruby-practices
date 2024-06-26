require 'date'

# 1行目。デフォルトでは今月今年を表示、-m -yで指定したらその月と年を表示。
m = 0
y = 0
if ARGV[1] && ARGV[3]
  m = ARGV[1].to_i
  y = ARGV[3].to_i
elsif ARGV[1]
  m = ARGV[1].to_i
  y = Date.today.year
else
  m = Date.today.month
  y = Date.today.year
end

puts "      #{m}月 #{y}"

# ２行目
puts "日 月 火 水 木 金 土"

# ３行目  1日の前にある空白を配列にする。
weeks = Date.new(y, m, 1).wday 
spaces = []
weeks.times do
  spaces << "  "
end

# その月の1日~末日までを配列にする。
first_day = Date.new(y, m, 1).day
last_day = Date.new(y, m, -1).day
days = []
(first_day..last_day).each do |i|
  days << i.to_s.rjust(2)
end

# 土曜日で改行されるようにする。
(spaces + days).each_slice(7) do |group|
  puts group.join(" ")
end
