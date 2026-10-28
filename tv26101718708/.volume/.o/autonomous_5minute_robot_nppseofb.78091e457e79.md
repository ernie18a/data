Calculation: Buy volume = volume × (close − low) ÷ (high − low) when high > low; otherwise 0
Calculation: Sell volume = volume × (high − close) ÷ (high − low) when high > low; otherwise 0
Long: current close > SMA of close on the current timeframe AND current close > close of the completed bar at the configured trend lookback AND buy volume > sell volume
Short: current close < SMA of close on the current timeframe AND current close < close of the completed bar at the configured trend lookback AND sell volume > buy volume
Exit: Long, low ≤ current close × (1 − stop-loss fraction) OR high ≥ current close × (1 + take-profit fraction)
Exit: Short, high ≥ current close × (1 + stop-loss fraction) OR low ≤ current close × (1 − take-profit fraction)