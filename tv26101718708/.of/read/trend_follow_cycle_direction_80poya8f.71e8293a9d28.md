Calculation: A timeframe value uses the last completed higher-timeframe bar or the last lower-timeframe bar within the chart bar; crossings compare the resulting series on consecutive chart bars.
Calculation: Bull zone = short-lookback RSI > long-lookback RSI AND MACD > signal AND (short-lookback RSI >= lower RSI threshold OR MACD < 0).
Calculation: Bear zone = short-lookback RSI < long-lookback RSI AND MACD < signal AND (short-lookback RSI < upper RSI threshold OR (short-lookback RSI > upper RSI threshold AND MACD > 0)).
Calculation: Chart zone = the applicable bull or bear zone subdivided by the lower, middle, and upper RSI thresholds; otherwise neutral. Remember the most recent non-neutral chart zone, initially neutral.
Long: Bull zone on the higher direction timeframe.
Short: Bear zone on the higher direction timeframe.
Long: Chart zone is a bull zone AND chart zone differs from the previously remembered non-neutral chart zone AND bull zone on the higher direction timeframe.
Short: Chart zone is a bear zone AND chart zone differs from the previously remembered non-neutral chart zone AND bear zone on the higher direction timeframe.
Long: Short-lookback RSI crosses above long-lookback RSI on the entry timeframe AND MACD crosses above its signal on the entry timeframe AND chart close > entry-timeframe session VWAP of typical price.
Short: Short-lookback RSI crosses below long-lookback RSI on the entry timeframe AND MACD crosses below its signal on the entry timeframe AND chart close < entry-timeframe session VWAP of typical price.
Exit: long, short-lookback RSI < long-lookback RSI on the exit timeframe AND MACD crosses below its signal on the exit timeframe AND short-lookback RSI < the middle RSI threshold AND exit-timeframe close < exit-timeframe session VWAP of typical price.
Exit: long, high >= setup entry price + chart-timeframe ATR at setup entry multiplied by a positive target multiplier.
Exit: short, low <= setup entry price - chart-timeframe ATR at setup entry multiplied by a positive target multiplier.