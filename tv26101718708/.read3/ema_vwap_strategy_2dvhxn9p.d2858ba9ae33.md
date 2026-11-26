Calculation: VWAP slope = 100 * (VWAP(close) - VWAP(close)[slope lookback]) / VWAP(close)[slope lookback]
Calculation: Long stop = at long entry, if stop type is ATR then entry price - ATR(high, low, close, ATR lookback) * ATR multiplier; if swing low/high then lowest(low, swing lookback); if slow EMA then EMA(close, slow lookback); if fixed percentage then entry price * (1 - stop percentage / 100)
Calculation: Short stop = at short entry, if stop type is ATR then entry price + ATR(high, low, close, ATR lookback) * ATR multiplier; if swing low/high then highest(high, swing lookback); if slow EMA then EMA(close, slow lookback); if fixed percentage then entry price * (1 + stop percentage / 100)
Calculation: Long target = entry price + (entry price - long stop) * risk/reward ratio
Calculation: Short target = entry price - (short stop - entry price) * risk/reward ratio
Long: EMA(close, fast lookback) crosses above VWAP(close) AND EMA(close, fast lookback) > EMA(close, slow lookback) AND VWAP slope > 0 AND abs(VWAP slope) >= VWAP flat threshold AND (weekday-only filter is disabled OR dayofweek(datetime) is Monday-Friday)
Short: EMA(close, fast lookback) crosses below VWAP(close) AND EMA(close, fast lookback) < EMA(close, slow lookback) AND VWAP slope < 0 AND abs(VWAP slope) >= VWAP flat threshold AND (weekday-only filter is disabled OR dayofweek(datetime) is Monday-Friday)
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target