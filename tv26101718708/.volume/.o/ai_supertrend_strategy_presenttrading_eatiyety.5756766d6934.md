計算：SuperTrend＝以成交量加權均線作中線，加減 ATR 倍數形成上下軌；上下軌依前值與前收盤價延續或更新，收盤價突破反向軌時切換方向
計算：KNN 加權分類＝以近回看資料的 SuperTrend 值作樣本，樣本標籤為加權收盤均線高於加權 SuperTrend 均線；依 SuperTrend 值與當前值的距離選最近鄰，以距離倒數加權標籤
做多：KNN 加權分類等於 1 且前一根 KNN 加權分類不等於 1，或 SuperTrend 方向由空轉多且 KNN 加權分類等於 1
做空：KNN 加權分類等於 0 且前一根 KNN 加權分類不等於 0，或 SuperTrend 方向由多轉空且 KNN 加權分類等於 0
出場：多倉，(SuperTrend 方向不為多或 KNN 加權分類不等於 1) 且最低價低於或等於 SuperTrend 下方 ATR 倍數停損價
出場：空倉，(SuperTrend 方向不為空或 KNN 加權分類不等於 0) 且最高價高於或等於 SuperTrend 上方 ATR 倍數停損價