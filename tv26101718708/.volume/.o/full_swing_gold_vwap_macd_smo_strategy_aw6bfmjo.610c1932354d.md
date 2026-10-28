Calculation: monthly VWAP = volume-weighted average of bar lows accumulated from the start of the current month, including the forming month
Calculation: SMO oscillator = TSI(close, shorter lookback, longer lookback) − EMA(TSI(close, shorter lookback, longer lookback), signal lookback)
Long: close > monthly VWAP AND MACD histogram > previous bar's MACD histogram AND SMO oscillator > 0
Short: close < monthly VWAP AND MACD histogram < previous bar's MACD histogram AND SMO oscillator < 0
Exit: long, close < monthly VWAP AND MACD histogram < previous bar's MACD histogram AND SMO oscillator < 0 OR high >= entry price + close × take-profit percentage OR low <= entry price − close × stop-loss percentage
Exit: short, close > monthly VWAP AND MACD histogram > previous bar's MACD histogram AND SMO oscillator > 0 OR low <= entry price − close × take-profit percentage OR high >= entry price + close × stop-loss percentage