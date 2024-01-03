# frozen_string_literal: true

def calculate_strike_points(next_frame, after_next_frame)
  if next_frame[0] == 10 && after_next_frame[0] == 10
    30
  elsif next_frame[0] == 10
    20 + after_next_frame[0]
  else
    10 + next_frame.sum
  end
end

scores = ARGV[0].split(',')
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end
frames = shots.each_slice(2).to_a

point = 0
frames.each_with_index do |frame, index|
  next_frame = frames[index + 1]
  after_next_frame = frames[index + 2]
  if frame[0] == 10
    point += calculate_strike_points(next_frame, after_next_frame)
    break if index >= 9
  elsif frame.sum == 10
    point += if index >= 9
               frame.sum
             else
               frame.sum + next_frame[0]
             end
  else
    point += frame.sum
  end
end

p point
