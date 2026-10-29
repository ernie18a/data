Calculation: high-volume threshold = volume SMA × multiplier
Long: close > prior-bar highest high over lookback AND volume > volume SMA AND (trend filter disabled OR short-term EMA > long-term EMA)
Long: high > prior-bar highest high over lookback AND close < prior-bar highest high over lookback AND volume > high-volume threshold AND (trend filter disabled OR short-term EMA ≤ long-term EMA)
Short: close < prior-bar lowest low over lookback AND volume > volume SMA AND (trend filter disabled OR short-term EMA < long-term EMA)
Short: low < prior-bar lowest low over lookback AND close > prior-bar lowest low over lookback AND volume > high-volume threshold AND (trend filter disabled OR short-term EMA ≥ long-term EMA)