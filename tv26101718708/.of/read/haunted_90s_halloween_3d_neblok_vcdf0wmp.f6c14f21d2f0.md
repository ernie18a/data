Long: Close >= open
Short: Close < open
Long: Previous reference-timeframe close != 0 AND (close - previous reference-timeframe close) / previous reference-timeframe close >= 0
Short: Previous reference-timeframe close != 0 AND (close - previous reference-timeframe close) / previous reference-timeframe close < 0
Long: The low of a candidate bar is <= the lows of each of an equal number of preceding bars AND < the lows of each of the subsequent bars; evaluate when the last subsequent bar closes
Short: The high of a candidate bar is >= the highs of each of an equal number of preceding bars AND > the highs of each of the subsequent bars; evaluate when the last subsequent bar closes
Calculation: Previous reference-timeframe close = close of the last completed reference-timeframe bar at the start of the chart bar; the reference timeframe may be higher or lower than the chart timeframe