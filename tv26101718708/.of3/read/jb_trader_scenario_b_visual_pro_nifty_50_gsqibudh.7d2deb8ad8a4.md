Calculation: Bullish state = direction(SuperTrend(factor, lookback)) < 0 AND close > VWAP(close)
Calculation: Bearish state = direction(SuperTrend(factor, lookback)) > 0 AND close < VWAP(close)
Long: Bullish state
Long: Bullish state AND NOT Bullish state[1]
Long: Bullish state AND (session filter disabled OR within configured session)
Short: Bearish state
Short: Bearish state AND NOT Bearish state[1]
Short: Bearish state AND (session filter disabled OR within configured session)
Exit: Long, (direction(SuperTrend(factor, lookback)) > 0 AND NOT (Bearish state AND (session filter disabled OR within configured session))) OR (session filter enabled AND outside configured session)
Exit: Short, (direction(SuperTrend(factor, lookback)) < 0 AND NOT (Bullish state AND (session filter disabled OR within configured session))) OR (session filter enabled AND outside configured session)