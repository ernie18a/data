Calculation: Requested high, low, and close = high, low, and close from a configurable timeframe that may be higher or lower than the chart timeframe. For a higher timeframe, use the last completed bar on historical chart bars; for a lower timeframe, use the last intrabar within each chart bar.
Calculation: Short-range position = (requested close - lowest requested low over the shorter chart-bar lookback) / (highest requested high over the shorter chart-bar lookback - lowest requested low over the shorter chart-bar lookback).
Calculation: Long-range position = (requested close - lowest requested low over the longer chart-bar lookback) / (highest requested high over the longer chart-bar lookback - lowest requested low over the longer chart-bar lookback).
Calculation: Strength = 100 * long-range position * short-range position.
Calculation: Selling pressure = 100 * (1 - long-range position) * (1 - short-range position).
Long: Strength on the previous chart bar crossed above the strength entry threshold AND selling pressure on the previous chart bar < the selling-pressure filter threshold.
Long: Selling pressure on the previous chart bar crossed below the extreme selling-pressure threshold.
Exit: long, strength on the previous chart bar crossed below the exit threshold.