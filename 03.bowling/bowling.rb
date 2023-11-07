# frozen_string_literal: true

scores = ARGV[0].split(',')
# 引数を数字に変換する。
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

# １フレームごとに配列を作る。
flames = []
shots.each_slice(2) do |s|
  flames << s
end

# ストライクの場合、スペアの場合で加算されるように書く。
point = 0
flames.each_with_index do |frame, index|
  next_flame = flames[index + 1]
  third_frame = flames[index + 2]
  if frame[0] == 10 # ストライク
    # 10フレーム目がすべてXだった場合
    if index == 9 && next_flame[0] == 10 && third_frame[0] == 10
      point += frame.sum + 20
      break
    # 最後の投球がストライクだった、もしくは10フレーム目の1投目がストライクの場合
    elsif index == flames.length - 1 || index == 9
      point += 10
    # ストライクが２回以上続いた場合
    elsif next_flame[0] == 10
      point += frame.sum + 10 + third_frame[0]
    # ストライクが1回
    else
      point += frame.sum + next_flame.sum
    end

  elsif frame.sum == 10 # スペア
    # 10フレーム目がスペアだった場合
    point += if index >= 9
               frame.sum
             else
               frame.sum + next_flame[0]
             end
  else
    point += frame.sum
  end
end

p point
