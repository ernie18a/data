Calculation: ATR = Wilder-smoothed average true range over a lookback
Calculation: Stop4 = a ratcheting ATR trailing stop with a trend state (initially up). While trend is up, Stop4 = max(close - k*ATR, previous Stop4). While trend is down, Stop4 = min(close + k*ATR, previous Stop4). On a trend flip, Stop4 resets to close - k*ATR (new trend up) or close + k*ATR (new trend down). k is the outermost band's ATR multiplier.
Long: trend is down AND close > previous bar's Stop4 (trend flips to up)
Short: trend is up AND close < previous bar's Stop4 (trend flips to down)
Exit: long, close < previous bar's Stop4
Exit: short, close > previous bar's Stop4