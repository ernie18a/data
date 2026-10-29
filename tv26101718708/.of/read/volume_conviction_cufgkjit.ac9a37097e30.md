Calculation: average volume = simple moving average of volume over a lookback
Calculation: body ratio = absolute(close - open) / (high - low), or 0 when high = low
Long: close >= open AND body ratio >= conviction body threshold AND volume >= average volume × high-volume multiplier
Short: close < open AND body ratio >= conviction body threshold AND volume >= average volume × high-volume multiplier