【指標】對最近 N 根 close（N 為回歸長度，可固定，或取最近 N 根內最高 high／最低 low 距今的根數，下限 10）做最小平方法線性回歸，x 為 0..N-1。mid_end 為回歸線在最新一根的值，slope 為斜率。殘差 e_i = close_i − 回歸線_i，dev = 2 × sqrt(mean(e_i²))，top = mid_end + dev，bot = mid_end − dev。percent = 100 × (close − bot) / (top − bot)，close 在 bot 為 0、在 mid 為 50、在 top 為 100。R = N 根 close 與 x 的 Pearson 相關係數，R>0 為上升趨勢，R<0 為下降趨勢。

【濾網比較規則】percent 條件有「高於 P」（percent ≥ P）與「低於 P」（percent ≤ P）兩種。R 條件有五種：「R 高於 r」（R ≥ r）、「R 低於 r」（R ≤ r）、「|R| 高於 |r|」（|R| ≥ |r|）、「|R| 低於 |r|」（|R| ≤ |r|）、「0 到 r」（|R| ≤ |r|）。條件可以不設，不設的條件視為通過。已設定的 percent 與 R 條件必須全部通過，且回歸長度須大於 1。可同時用多條回歸（不同長度或錨點），每條各自檢查，須全部通過；也可再對各回歸的 percent 與 R 取平均後套用同樣條件。

【做多（進場）】在已設定的條件全部通過時成立。典型設定為「趨勢向上時逢低買」：percent ≤ 0（close 跌破下軌）且 R ≥ 0（回歸斜率向上）。

【出場】條件組合同上，另設一組門檻，全部通過即出場。典型設定為 percent ≥ 100（close 突破上軌）且 R ≤ 0。

進場與出場兩組條件各自獨立，可在同一根同時成立。