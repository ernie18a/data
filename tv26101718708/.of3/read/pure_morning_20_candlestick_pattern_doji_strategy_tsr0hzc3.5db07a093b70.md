Long: Doji(open, close, Doji tolerance) AND close > EMA(close, EMA lookback) AND (max-loss filter off OR close - Lowest(low, stop lookback) < close × max-loss percentage / 100)
Long: Morning Doji Star(open, high, low, close, MDS tolerance, first-candle body-to-range threshold) AND close > EMA(close, EMA lookback) AND (max-loss filter off OR close - Lowest(low, stop lookback) < close × max-loss percentage / 100)
Short: Doji(open, close, Doji tolerance) AND close < EMA(close, EMA lookback)
Short: Morning Doji Star(open, high, low, close, MDS tolerance, first-candle body-to-range threshold) AND close < EMA(close, EMA lookback)
Exit: long, high >= entry price × (1 + take-profit percentage / 100)
Exit: long, lowest-low stop selected AND low <= Lowest(low, stop lookback)
Exit: long, percentage stop selected AND low <= entry price × (1 - stop-loss percentage / 100)
Exit: long, high >= entry price + close × trailing-threshold percentage / 100 AND low <= Highest(high since trailing activation) - close × trailing-offset percentage / 100
Exit: long, MFI(close, MFI lookback) crosses above MFI threshold