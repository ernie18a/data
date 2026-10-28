Calculation: LR open and LR close = current-bar endpoints of linear regression over the same lookback applied to open and close, respectively
Calculation: Signal line = simple moving average of LR close over a shorter lookback
Long: LR close >= LR open
Short: LR close < LR open
Long: LR close > signal line AND previous LR close <= previous signal line AND (volume > volume SMA OR volume filter disabled) AND (RSI < 70 OR RSI filter disabled) AND bar index >= max(3 × LR lookback, EMA lookback + 5) AND bar is confirmed
Short: LR close < signal line AND previous LR close >= previous signal line AND (volume > volume SMA OR volume filter disabled) AND (RSI > 30 OR RSI filter disabled) AND bar index >= max(3 × LR lookback, EMA lookback + 5) AND bar is confirmed
Long: On each configured timeframe, LR close >= LR open, calculated from that timeframe’s current bar with lookahead off
Short: On each configured timeframe, LR close < LR open, calculated from that timeframe’s current bar with lookahead off