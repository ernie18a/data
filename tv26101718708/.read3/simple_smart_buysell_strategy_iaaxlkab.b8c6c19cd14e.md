Long: close > VWAP(close) AND EMA(close, shorter lookback) > EMA(close, longer lookback) AND low <= EMA(close, shorter lookback) AND close > high[1]
Short: close < VWAP(close) AND EMA(close, shorter lookback) < EMA(close, longer lookback) AND high >= EMA(close, shorter lookback) AND close < low[1]
Exit: long, low <= close - ATR(lookback) OR high >= close + target multiple * ATR(lookback)
Exit: short, high >= close + ATR(lookback) OR low <= close - target multiple * ATR(lookback)