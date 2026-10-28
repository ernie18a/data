Calculation: Session VWAP = cumulative (hlc3 × volume) / cumulative volume since session start
Long: current bar is within the configured session AND position is flat AND close ≤ session VWAP − minimum VWAP distance AND RSI(close) ≤ oversold threshold AND close > open AND previous close < previous open
Short: current bar is within the configured session AND position is flat AND close ≥ session VWAP + minimum VWAP distance AND RSI(close) ≥ overbought threshold AND close < open AND previous close > previous open
Exit: long, low ≤ entry price − ATR × stop multiple OR high ≥ entry price + ATR × target multiple OR bars since entry ≥ configured time limit
Exit: short, high ≥ entry price + ATR × stop multiple OR low ≤ entry price − ATR × target multiple OR bars since entry ≥ configured time limit