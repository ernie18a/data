Calculation: Bullish hammer = close > open AND open - low > wick factor × abs(close - open) AND high - close < wick factor × abs(close - open)
Calculation: Bullish engulfing = close > open AND close > close[1] AND open < open[1] AND close > open[1]
Calculation: Bullish momentum candle = close > open AND abs(close - open) > SMA(abs(close - open), candle-body lookback) AND close > high - (high - low) × close-position fraction
Long: Bullish hammer
Long: Bullish engulfing
Long: Bullish momentum candle
Long: EMA(close, EMA lookback) crosses above VWAP within the crossover recency lookback AND low is between VWAP - retest buffer and VWAP + retest buffer AND close > VWAP AND close > high of the last completed T1 bar, carried onto chart bars AND (Bullish hammer OR Bullish engulfing OR Bullish momentum candle) AND datetime is within the session parameter
Exit: long, high >= entry price × (1 + take-profit percentage) OR low <= VWAP recorded at entry × (1 - stop-loss percentage) OR datetime is at the forced-exit time parameter