Calculation: Resistance = latest confirmed pivot high, using equal numbers of chart bars on each side; update it on the confirmation bar.
Calculation: Support = latest confirmed pivot low, using the same pivot lookback on each side; update it on the confirmation bar.
Calculation: Zone width = chart-timeframe ATR multiplied by a zone-width parameter.
Calculation: Safe body = max(abs(close - open), minimum price increment).
Calculation: Candle range = max(high - low, minimum price increment).
Calculation: Bearish rejection = high >= resistance - zone width AND low <= resistance + zone width AND ((high - max(open, close) >= safe body * wick-ratio parameter AND close <= low + candle range * close-location parameter) OR (engulfing enabled = true AND close < open AND close < previous low AND open >= previous close)).
Calculation: Bullish rejection = high >= support - zone width AND low <= support + zone width AND ((min(open, close) - low >= safe body * wick-ratio parameter AND close >= high - candle range * close-location parameter) OR (engulfing enabled = true AND close > open AND close > previous high AND open <= previous close)).
Long: Bullish rejection = true.
Short: Bearish rejection = true.
Exit: long, bearish rejection = true AND (higher-timeframe KAMA filter enabled = false OR close > KAMA of the last completed higher-timeframe bar).
Exit: short, bullish rejection = true AND (higher-timeframe KAMA filter enabled = false OR close < KAMA of the last completed higher-timeframe bar).