Calculation: Envelope basis = EMA of a selected price source; envelope bands = basis plus or minus a configurable multiplier of the standard deviation of the same source over the EMA lookback.
Calculation: VWAP bands = VWAP of (high + low + close) / 3, reset at each trading-day boundary, plus or minus a configurable multiplier of the standard deviation of (close - VWAP) over the envelope lookback.
Calculation: Bullish rejection = close > open AND min(open, close) - low > a configurable multiple of abs(close - open) AND close > low + a configurable fraction of (high - low).
Calculation: Bearish rejection = close < open AND high - max(open, close) > the same multiple of abs(close - open) AND close < high - the same fraction of (high - low).
Long: low < lower envelope band AND low < lower VWAP band.
Short: high > upper envelope band AND high > upper VWAP band AND NOT (low < lower envelope band AND low < lower VWAP band).
Long: RSI of close <= configurable oversold threshold.
Short: RSI of close >= configurable overbought threshold.
Long: bullish rejection.
Short: bearish rejection.
Long: completed bar AND low < lower envelope band AND low < lower VWAP band AND close > lower envelope band AND (RSI filter disabled OR RSI of close <= oversold threshold) AND (volume filter disabled OR volume >= SMA of volume multiplied by a configurable factor) AND (rejection filter disabled OR bullish rejection) AND (no prior setup signal OR bars since the most recent long or short setup signal > configurable cooldown).
Short: completed bar AND high > upper envelope band AND high > upper VWAP band AND close < upper envelope band AND (RSI filter disabled OR RSI of close >= overbought threshold) AND (volume filter disabled OR volume >= SMA of volume multiplied by the same factor) AND (rejection filter disabled OR bearish rejection) AND (no prior setup signal OR bars since the most recent long or short setup signal > the same cooldown).
Exit: long, low <= entry price multiplied by (1 - configurable stop fraction) OR high >= entry price + entry price multiplied by the stop fraction and a configurable reward multiple.
Exit: short, high >= entry price multiplied by (1 + the same stop fraction) OR low <= entry price - entry price multiplied by the stop fraction and the same reward multiple.