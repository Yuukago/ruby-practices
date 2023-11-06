require 'minitest/autorun'

class SampleTest < Minitest::Test
  def test_sample
    assert_equal 164, 6, 3, 9, 0, 0, 3, 8, 2, 7, 3, X, 9, 1, 8, 0, X, X, X, X
  end
end

class SampleTest < Minitest::Test
  def test_sample
    scores = %w[6 3 9 0 0 3 8 2 7 3 X 9 1 8 0 X X X X]

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

    # フレームごとに配列をスライスする。
    flames = []
    shots.each_slice(2) do |s|
      flames << s
    end

    # ストライクの場合、スペアの場合で加算されるように書く。
    point = 0
    flames.each_with_index do |frame, index|
      if frame[0] == 10 # ストライク
        # 10投目
        if index == 9
          point += frame.sum + flames[index + 1].sum
          break
        # ストライクが２回以上続いた場合
        elsif flames[index + 1][0] == 10
          point += frame.sum + flames[index + 1].sum + flames[index + 2][0]
        # 通常のストライクの計算
        else
          point += frame.sum + flames[index + 1].sum
        end
      elsif frame.sum == 10 # スペア
        point += if index == 9
                   frame.sum
                 else
                   frame.sum + flames[index + 1][0]
                 end
      else
        point += frame.sum
      end
    end

    assert_equal 164, point
  end
end
