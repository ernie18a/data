Calculation: Doji = abs(open - close) <= (high - low) × doji-size parameter
Calculation: Long stop price = high if the previous bar's abs(close - open) / (high - low) > long-candle-ratio parameter and its range > current range; otherwise max(current high, previous high)
Calculation: Short stop price = low if the previous bar's abs(close - open) / (high - low) > long-candle-ratio parameter and its range > current range; otherwise min(current low, previous low)
Long: Doji AND (volume filter disabled OR volume > EMA(volume, volume lookback)) AND high >= Long stop price
Short: Doji AND (volume filter disabled OR volume > EMA(volume, volume lookback)) AND low <= Short stop price
Exit: Long, take-profit/stop-loss enabled AND (low <= entry price - stop-loss distance OR high >= entry price + take-profit distance) OR take-profit/stop-loss disabled AND (high >= entry price + take-profit distance OR (Doji AND close < low))
Exit: Short, take-profit/stop-loss enabled AND (high >= entry price + stop-loss distance OR low <= entry price - take-profit distance) OR take-profit/stop-loss disabled AND (low <= entry price - take-profit distance OR (Doji AND close > high))