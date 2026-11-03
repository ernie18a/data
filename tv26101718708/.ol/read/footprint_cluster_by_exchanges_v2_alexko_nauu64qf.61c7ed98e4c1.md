Calculation: POC position = (footprint point-of-control price − low) / (high − low)
Calculation: Footprint delta = footprint buy volume − footprint sell volume
Calculation: Delta percentage = absolute footprint delta / footprint total volume × 100
Calculation: ATR = average true range over a lookback
Calculation: Volume anomaly = selected volume metric exceeds its prior rolling average or maximum by a configured percentage; the current bar is excluded
Long: bar is confirmed AND POC position ≤ configured lower-range threshold AND (delta confirmation is disabled OR footprint delta > 0) AND (minimum delta percentage is disabled OR delta percentage ≥ threshold) AND (minimum volume is disabled OR footprint total volume ≥ threshold) AND (minimum range is disabled OR high − low ≥ ATR × threshold) [cluster mode]
Short: bar is confirmed AND POC position ≥ 1 − configured lower-range threshold AND (delta confirmation is disabled OR footprint delta < 0) AND (minimum delta percentage is disabled OR delta percentage ≥ threshold) AND (minimum volume is disabled OR footprint total volume ≥ threshold) AND (minimum range is disabled OR high − low ≥ ATR × threshold) [cluster mode]
Long: bar is confirmed AND volume anomaly AND (footprint delta ≥ 0 OR (footprint delta unavailable AND close ≥ open)) [all-bars anomaly mode]
Short: bar is confirmed AND volume anomaly AND (footprint delta < 0 OR (footprint delta unavailable AND close < open)) [all-bars anomaly mode]