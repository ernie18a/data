Calculation: Body ratio = if high > low, abs(close − open) / (high − low); otherwise 0
Calculation: Average volume = simple moving average of volume over a lookback
Long: close >= open AND body ratio >= large-body threshold AND volume >= average volume × high-volume multiplier
Short: close < open AND body ratio >= large-body threshold AND volume >= average volume × high-volume multiplier