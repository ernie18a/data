Long: SMA(close, lookback, T1, still-forming bar value on chart bars) > SMA(open, same lookback, T1, still-forming bar value on chart bars) AND position is flat or short
Short: SMA(close, lookback, T1, still-forming bar value on chart bars) < SMA(open, same lookback, T1, still-forming bar value on chart bars) AND position is flat or long AND trade-side setting permits short entries
Exit: long, SMA(close, lookback, T1, still-forming bar value on chart bars) < SMA(open, same lookback, T1, still-forming bar value on chart bars)
Exit: short, SMA(close, lookback, T1, still-forming bar value on chart bars) > SMA(open, same lookback, T1, still-forming bar value on chart bars) AND trade-side setting permits short entries
Exit: long, stop loss enabled AND low <= entry price * (1 - stop-loss parameter / 100)
Exit: long, take profit enabled AND high >= entry price * (1 + take-profit parameter / 100)