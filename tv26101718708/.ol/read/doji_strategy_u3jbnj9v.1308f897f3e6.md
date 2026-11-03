Calculation: Doji = abs(close - open) <= (high - low) * doji threshold
Calculation: Long stop = current high if previous bar's body/range > long-candle threshold AND previous bar's range > current range; otherwise max(current high, previous high)
Calculation: Short stop = current low if previous bar's body/range > long-candle threshold AND previous bar's range > current range; otherwise min(current low, previous low)
Long: Doji AND (volume filter disabled OR volume > volume EMA) AND high >= Long stop
Short: Doji AND (volume filter disabled OR volume < volume EMA) AND low <= Short stop
Exit: long, high >= entry price + take-profit distance OR low <= entry price - stop-loss distance
Exit: short, low <= entry price - take-profit distance OR high >= entry price + stop-loss distance