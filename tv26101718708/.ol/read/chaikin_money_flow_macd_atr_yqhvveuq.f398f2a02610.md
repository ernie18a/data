Calculation: EMA = exponential moving average of close on the configured timeframe via lookahead-off; when that timeframe is higher than the chart timeframe, use its last completed bar.
Long: MACD crosses above its signal line AND MACD > 0 AND Chaikin Money Flow > 0 AND close > EMA AND position is flat
Short: MACD crosses below its signal line AND MACD < 0 AND Chaikin Money Flow < 0 AND close < EMA AND position is flat
Exit: long, low <= entry price - ATR at entry × stop factor OR high >= entry price + ATR at entry × profit factor
Exit: short, high >= entry price + ATR at entry × stop factor OR low <= entry price - ATR at entry × profit factor