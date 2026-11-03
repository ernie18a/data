Calculation: Signed volume = volume when close > open; otherwise −volume
Calculation: CVD wave = session-reset cumulative sum of signed volume
Calculation: CVD signal line = EMA of CVD wave
Calculation: Recent CVD high = highest CVD wave over the signal line’s smoothing lookback
Calculation: Short-term volume average = SMA of volume with a shorter lookback than the long-term volume average
Calculation: Long-term volume average = SMA of volume with a longer lookback than the short-term volume average
Calculation: CVD change = current signed volume minus previous bar’s signed volume
Long: CVD wave crosses above CVD signal line AND CVD wave equals recent CVD high
Short: CVD wave >= CVD signal line AND short-term volume average < a threshold fraction of the long-term volume average AND (CVD wave < recent CVD high OR CVD change < 0)