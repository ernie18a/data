Calculation: Relative volume = current volume divided by its moving average.
Calculation: ATR expansion = average true range is above its moving average.
Calculation: Fast EMA = EMA of close with a shorter lookback than the slow EMA.
Calculation: Slow EMA = EMA of close with a longer lookback than the fast EMA.
Calculation: Multi-timeframe uptrend = on each higher timeframe, close is above its EMA.
Calculation: Multi-timeframe downtrend = on each higher timeframe, close is at or below its EMA.
Long: (close > fast EMA AND fast EMA > slow EMA AND close > VWAP AND Supertrend direction > 0 AND relative volume exceeds its threshold AND ATR expansion AND multi-timeframe uptrend using the last completed higher-timeframe bars) OR (multi-timeframe uptrend using the last completed higher-timeframe bars AND close > VWAP)
Short: (close < fast EMA AND fast EMA < slow EMA AND close < VWAP AND Supertrend direction < 0 AND relative volume exceeds its threshold AND ATR expansion AND multi-timeframe downtrend using the last completed higher-timeframe bars) OR (multi-timeframe downtrend using the last completed higher-timeframe bars AND close < VWAP)