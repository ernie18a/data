Calculation: Highest prior down-bar volume = the highest volume among prior bars where close < previous close, over a lookback period.
Calculation: Price increase (%) = (current close - previous close) / previous close × 100.
Long: fast EMA crosses above slow EMA AND RSI >= its minimum threshold OR current close >= previous close AND volume > highest prior down-bar volume OR volume >= its minimum threshold AND price increase (%) >= its minimum threshold OR volume > volume EMA × its multiplier AND close > open
Short: fast EMA crosses below slow EMA AND RSI <= its maximum threshold OR volume > volume EMA × its multiplier AND open > close
Exit: long, fast EMA crosses below slow EMA AND RSI <= its maximum threshold