Calculation: Bar range percentile rank = percentile rank of high − low over a lookback of chart-timeframe bars including the current bar.
Calculation: Volume percentile rank = percentile rank of volume over a lookback of chart-timeframe bars including the current bar.
Calculation: Prior high/low = highest high / lowest low over a lookback of prior chart-timeframe bars, excluding the current bar.
Calculation: Buying climax = close > previous close AND volume equals the highest volume in its lookback AND bar range percentile rank ≥ upper range threshold.
Calculation: Selling climax = close < previous close AND volume equals the highest volume in its lookback AND bar range percentile rank ≥ upper range threshold.
Calculation: Upthrust = volume > 0 AND high ≥ prior high AND (close − low) / (high − low) ≤ lower close-position threshold AND volume percentile rank ≥ upper volume threshold.
Calculation: Shakeout = volume > 0 AND low ≤ prior low AND (close − low) / (high − low) ≥ upper close-position threshold AND volume percentile rank ≥ upper volume threshold.
Calculation: Stopping volume = volume > 0 AND close < previous close AND bar range percentile rank ≥ upper range threshold AND volume percentile rank ≥ high-volume threshold AND (close − low) / (high − low) ≥ lower close-position threshold.
Calculation: No demand = volume > 0 AND close > previous close AND bar range percentile rank ≤ low range threshold AND volume percentile rank ≤ low volume threshold.
Calculation: No supply = volume > 0 AND close < previous close AND bar range percentile rank ≤ low range threshold AND volume percentile rank ≤ low volume threshold.
Long: Selling climax OR shakeout OR stopping volume OR no supply
Short: NOT (selling climax OR shakeout OR stopping volume OR no supply) AND (buying climax OR upthrust OR no demand)