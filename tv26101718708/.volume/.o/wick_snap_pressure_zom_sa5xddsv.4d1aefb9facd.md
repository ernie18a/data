Calculation: QStick = moving average of close minus open over a lookback
Calculation: Lower-wick/body ratio = (min(open, close) - low) / max(abs(close - open), minimum tick size)
Long: Lower-wick/body ratio >= threshold AND QStick > 0 AND QStick > its value on the previous bar
Short: Upper-wick/body ratio >= threshold AND QStick < 0 AND QStick < its value on the previous bar