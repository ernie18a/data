Calculation: Confirmed swing high/low = pivot high/low with equal lookback bars on both sides; use the most recently confirmed pivot
Calculation: Bullish/bearish structure break = close crosses above/below the most recent confirmed swing high/low, with the close-to-pivot distance greater than ATR × displacement threshold
Calculation: Relative volume = volume / simple moving average of volume over a longer lookback
Calculation: Candle delta = ((close − low) / range × volume − (high − close) / range × volume) / max(volume, 1) × 100, where range = max(high − low, minimum tick)
Calculation: Smoothed delta = EMA of candle delta
Calculation: Bullish/bearish pressure = close >/< open AND candle delta >/< 0 AND smoothed delta >/< 0
Calculation: Body percentage = abs(close − open) / max(high − low, minimum tick) × 100
Calculation: Fast/slow flow = EMA of hlc3 using shorter/longer lookbacks, respectively
Calculation: Higher-timeframe bias = fast EMA of hlc3 >/< slow EMA of hlc3 AND smoothed delta >=/<= 0, calculated from the last completed bars of a higher timeframe
Calculation: Bullish/bearish score = 2 points for a bullish/bearish structure break, plus 1 point each for relative volume >= its threshold, bullish/bearish pressure, body percentage >= its threshold AND close >/< fast flow, fast flow >/< slow flow, and supportive higher-timeframe bias
Long: bullish structure break AND supportive higher-timeframe bias AND bullish score >= minimum catalyst score
Short: bearish structure break AND supportive higher-timeframe bias AND bearish score >= minimum catalyst score