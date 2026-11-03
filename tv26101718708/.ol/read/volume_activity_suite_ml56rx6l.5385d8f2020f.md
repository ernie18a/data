Calculation: Log-volume z-score = z-score of log volume against the preceding lookback bars, excluding the current bar; use mean and standard deviation or median and MAD according to the robust setting.
Calculation: Volume percentile = current volume’s rank within the lookback window including the current bar.
Calculation: Relative volume = current volume divided by the average volume over the preceding lookback bars.
Calculation: PVO = 100 × (fast EMA of volume − slow EMA of volume) / slow EMA of volume; the fast EMA lookback is shorter than the slow EMA lookback.
Calculation: High activity = selected Log-volume z-score ≥ its upper threshold, selected volume percentile ≥ its upper threshold, selected relative volume ≥ its upper threshold, or selected PVO > 0.
Calculation: Up day = close ≥ open, or close ≥ previous close, according to the selected direction basis.
Long: High activity AND up day
Short: High activity AND NOT up day