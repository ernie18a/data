Calculation: Smoothed volume = volume smoothed by a selected HMA, ALMA, EMA, or SMA over a lookback; the A and B versions use the same lookback and may use different smoothing methods
Calculation: Volume threshold = smoothed volume multiplied by its configured multiplier; thresholds A and B use their respective smoothed volume versions
Long: close > open AND ((volume >= Volume threshold A AND volume < Volume threshold B) OR volume >= Volume threshold B)
Short: close <= open AND ((volume >= Volume threshold A AND volume < Volume threshold B) OR volume >= Volume threshold B)