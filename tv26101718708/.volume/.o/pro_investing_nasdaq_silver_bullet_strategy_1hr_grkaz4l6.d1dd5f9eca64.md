計算：連續陽線數＝連續滿足 close > open 的根數；遇到 close ≤ open 歸零
計算：連續陰線數＝連續滿足 close < open 的根數；遇到 close ≥ open 歸零
做多：datetime 落在設定交易時段內，連續陽線數 ≥ 設定門檻，close > EMA(close, 設定回看期)，持倉數量＝0
做空：datetime 落在設定交易時段內，連續陰線數 ≥ 設定門檻，close < EMA(close, 設定回看期)，持倉數量＝0
出場：多單，low ≤ 進場價 × (1 − 停損百分比) 或 high ≥ 進場價 × (1 + 停利百分比)
出場：空單，high ≥ 進場價 × (1 + 停損百分比) 或 low ≤ 進場價 × (1 − 停利百分比)
出場：多單或空單，datetime 不在設定交易時段內