Calculation: buy volume = volume * (close - low) / (high - low) when high != low, otherwise 0
Calculation: sell volume = volume * (high - close) / (high - low) when high != low, otherwise 0
Long: close > SMA(close, moving-average lookback) AND close > close[trend lookback] AND buy volume > sell volume
Short: close < SMA(close, moving-average lookback) AND close < close[trend lookback] AND sell volume > buy volume
Exit: long, low <= entry price * (1 - stop-loss percentage) OR high >= entry price * (1 + take-profit percentage)
Exit: short, high >= entry price * (1 + stop-loss percentage) OR low <= entry price * (1 - take-profit percentage)