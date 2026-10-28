Calculation: Velocity = weighted mean of the short-, medium-, and long-term EMA changes, each change measured from its respective progressively longer lookback and divided by the ATR for that EMA length; apply the selected smoother once or twice.
Calculation: Stretch = weighted mean of the short-, medium-, and long-term distances from hlc3 to each EMA, each distance divided by the ATR for that EMA length; apply the selected smoother once or twice.
Long: (Velocity >= 0 AND Stretch >= 0) OR (Velocity >= 0 AND Stretch < 0)
Short: (Velocity < 0 AND Stretch >= 0) OR (Velocity < 0 AND Stretch < 0)