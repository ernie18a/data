Calculation: Body-to-volume efficiency = absolute value of (close - open) / volume
Calculation: Efficiency z-score = (body-to-volume efficiency - its 21-bar SMA) / its 21-bar standard deviation
Calculation: Volume z-score = (volume - its 21-bar SMA) / its 21-bar standard deviation
Calculation: Center of Gravity = RMA(close × volume, 9) / RMA(volume, 9)
Long: (Efficiency z-score > sensitivity threshold AND close > open AND (filter is All OR filter is Preferred AND hl2 < Center of Gravity OR filter is Distal AND hl2 > Center of Gravity)) OR (Volume z-score > sensitivity threshold AND close < open)
Short: (Efficiency z-score > sensitivity threshold AND close < open AND (filter is All OR filter is Preferred AND hl2 > Center of Gravity OR filter is Distal AND hl2 < Center of Gravity)) OR (Volume z-score > sensitivity threshold AND close > open)