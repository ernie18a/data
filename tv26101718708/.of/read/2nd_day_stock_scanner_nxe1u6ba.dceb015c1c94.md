Calculation: Percent change = 100 × (close − previous close) / previous close.
Calculation: Range position = 100 × (close − low) / (high − low) when high ≠ low; otherwise 50.
Calculation: Relative volume = 100 × volume / the simple average volume over the preceding lookback bars, excluding the current bar; undefined when that average is zero.
Calculation: Base match = absolute percent change ≥ move threshold AND (range position ≥ 100 − range threshold OR range position ≤ range threshold) AND relative volume > relative-volume threshold AND true range > previous bar's average true range.
Long: Base match AND percent change > 0 AND range position ≥ 100 − range threshold.
Short: Base match AND percent change ≤ 0 AND range position ≤ range threshold.
Short: Base match AND direction matching disabled AND labels enabled AND (percent change ≤ 0 OR range position < 100 − range threshold).