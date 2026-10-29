Calculation: Dow trend = On the chart timeframe, a confirmed swing high is the high from swingLen bars ago when it equals the highest high across the 2 × swingLen + 1 bars centered there; a confirmed swing low is the corresponding lowest low. Retain the most recent confirmed swing high and low. Start neutral; set trend up when close exceeds the retained swing high and trend is not already up; set trend down when close falls below the retained swing low and trend is not already down; otherwise retain the trend.
Long: EMA(close, length) > its value on the prior chart bar AND Dow trend is up AND ADX > threshold
Short: EMA(close, length) < its value on the prior chart bar AND Dow trend is down AND ADX > threshold
Exit: Short, Dow trend is up
Exit: Long, Dow trend is down
Exit: Long, (close - entry price) / entry price × 100 < stop-loss percentage
Exit: Short, (entry price - close) / entry price × 100 < stop-loss percentage
Exit: Long, after (close - entry price) / entry price × 100 reaches the break-even trigger percentage, low ≤ entry price × 1.001
Exit: Short, after (entry price - close) / entry price × 100 reaches the break-even trigger percentage, high ≥ entry price × 0.999
Exit: Long, high > entry price + ATR(50) × factor × target multiple; close 30% at each of target multiples 1, 2, and 3
Exit: Short, low < entry price - ATR(50) × factor × target multiple; close 30% at each of target multiples 1, 2, and 3