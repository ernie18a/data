Calculation: Market Z-score = (market capitalization − realized capitalization) / standard deviation of the market capitalization series
Calculation: Spread Z-score = 2-bar simple moving average of [(market Z-score − MVRV ratio − longer-lookback simple moving average of (market Z-score − MVRV ratio)) / longer-lookback standard deviation of (market Z-score − MVRV ratio)]; use last completed higher-timeframe bars for market capitalization and realized capitalization
Long: Spread Z-score crosses above the long-entry threshold (current value > threshold AND previous value ≤ threshold)
Short: Spread Z-score crosses below the short-entry threshold (current value < threshold AND previous value ≥ threshold)
Exit: Long, Spread Z-score crosses below the short-entry threshold (current value < threshold AND previous value ≥ threshold)
Exit: Short, Spread Z-score crosses above the long-entry threshold (current value > threshold AND previous value ≤ threshold)