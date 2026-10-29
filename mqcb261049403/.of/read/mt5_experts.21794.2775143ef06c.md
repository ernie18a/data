Calculation: Smoothed power-weighted average = calculate the weighted average of the selected price over a lookback, with weight (lookback - bar offset) raised to a configurable power; smooth it with a configurable moving-average method and length, then round to a configurable price increment.
Calculation: Trend = sign of the latest nonzero change in the smoothed power-weighted average; retain the preceding trend when the average is unchanged.
Long: Chart-timeframe trend > 0
Short: Chart-timeframe trend < 0
Long: For any of three independent systems, trend on its configured higher or lower timeframe at the last completed bar > 0 AND trend on the preceding bar <= 0
Short: For any of three independent systems, trend on its configured higher or lower timeframe at the last completed bar < 0 AND trend on the preceding bar >= 0
Exit: long, trend on the corresponding system's higher or lower timeframe at the last completed bar < 0 OR low <= entry price - stop distance OR high >= entry price + target distance
Exit: short, trend on the corresponding system's higher or lower timeframe at the last completed bar > 0 OR high >= entry price + stop distance OR low <= entry price - target distance