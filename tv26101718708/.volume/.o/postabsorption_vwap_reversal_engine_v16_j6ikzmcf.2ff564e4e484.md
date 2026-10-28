Calculation: Session VWAP = volume-weighted average of (high + low + close) / 3, reset at each active session
Calculation: Volume percentile = percentage of bars in the lookback, including the current bar, whose volume is less than or equal to the current bar's volume
Calculation: Body displacement / ATR = abs(close - open) / ATR
Long: bar is confirmed AND bar is in the active session AND volume percentile >= its threshold AND body displacement / ATR <= its threshold AND close < session VWAP AND abs(close - session VWAP) / ATR > the near-VWAP threshold
Short: bar is confirmed AND bar is in the active session AND volume percentile >= its threshold AND body displacement / ATR <= its threshold AND close > session VWAP AND abs(close - session VWAP) / ATR > the near-VWAP threshold
Exit: long, low <= signal-bar low - ATR × stop multiple OR high >= signal-bar session VWAP OR bars since entry >= reversal horizon
Exit: short, high >= signal-bar high + ATR × stop multiple OR low <= signal-bar session VWAP OR bars since entry >= reversal horizon