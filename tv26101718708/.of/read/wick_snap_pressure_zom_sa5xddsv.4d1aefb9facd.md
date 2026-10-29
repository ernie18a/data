Calculation: QStick = simple moving average of close minus open over a lookback
Long: (min(open, close) - low) / abs(close - open) >= wick/body threshold AND QStick > 0 AND QStick > prior-bar QStick
Short: (high - max(open, close)) / abs(close - open) >= wick/body threshold AND QStick < 0 AND QStick < prior-bar QStick