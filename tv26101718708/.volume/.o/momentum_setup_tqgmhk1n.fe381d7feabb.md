Calculation: Session VWAP = volume-weighted average of (high + low + close) / 3 from the current session through the current bar
Calculation: Daily VWAP = volume-weighted average of (high + low + close) / 3 from the start of the current day through the current bar
Long: close > EMA(shorter lookback) AND close > EMA(longer lookback) AND close > Session VWAP AND close > Daily VWAP AND volume > SMA(volume, lookback)
Short: close < EMA(shorter lookback) AND close < EMA(longer lookback) AND close < Session VWAP AND close < Daily VWAP AND volume > SMA(volume, lookback)