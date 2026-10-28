Calculation: EMA = exponential moving average of (high + low) / 2
Calculation: MACD histogram = MACD line minus its signal line; the MACD line is the faster moving average minus the slower moving average
Calculation: OBV average = simple moving average of OBV
Long: within the configured date range AND close > EMA AND close > previous close AND EMA > previous EMA AND MACD histogram > 0 AND previous MACD histogram < 0 AND RSI < overbought threshold AND OBV > OBV average
Short: within the configured date range AND close < EMA AND close < previous close AND EMA < previous EMA AND MACD histogram < 0 AND previous MACD histogram > 0 AND RSI > oversold threshold AND OBV < OBV average
Exit: long, short condition
Exit: short, long condition