Calculation: Ignite = close > open AND abs(close - open) >= SMA(abs(close - open), medium lookback) * ignite-size multiple
Calculation: Pullback = close < open AND Ignite[1] AND abs(close - open) < abs(close[1] - open[1]) * maximum pullback fraction AND high > close[1] AND low < close[1]
Calculation: Confirmation = close > open AND Pullback[1] AND abs(close - open) > abs(close[2] - open[2]) * minimum confirmation fraction AND open > close[1]
Long: Ignite
Long: Pullback
Long: Confirmation
Long: position is flat AND Confirmation AND SMA(close, long-term lookback)[2] > SMA(close, medium-term lookback)[2] AND SMA(close, medium-term lookback)[2] > SMA(close, short-term lookback)[2] AND close[2] < SMA(close, short-term lookback)[2]
Exit: long, low <= the entry setup's Ignite low OR high >= the entry setup's Confirmation open + (the entry setup's Confirmation open - the entry setup's Ignite low) * reward-to-risk multiple