Calculation: Session-smoothed VWAP z-score = EMA of (close − session VWAP) / session volume-weighted standard deviation; session VWAP and standard deviation use cumulative source-price weights max(volume, 1), and the EMA resets each session. Valid only after the minimum in-session bar count and when standard deviation > 0.
Long: Current z-score > extreme threshold AND previous z-score ≤ extreme threshold AND bar is confirmed
Short: Current z-score < −extreme threshold AND previous z-score ≥ −extreme threshold AND bar is confirmed
Exit: Long, bar is confirmed AND current z-score > 0 AND previous z-score ≤ 0 AND an earlier score in the same session had absolute value ≥ extreme threshold
Exit: Long, bar is confirmed AND current z-score < 0 AND previous z-score ≥ 0 AND an earlier score in the same session had absolute value ≥ extreme threshold
Exit: Short, bar is confirmed AND current z-score > 0 AND previous z-score ≤ 0 AND an earlier score in the same session had absolute value ≥ extreme threshold
Exit: Short, bar is confirmed AND current z-score < 0 AND previous z-score ≥ 0 AND an earlier score in the same session had absolute value ≥ extreme threshold