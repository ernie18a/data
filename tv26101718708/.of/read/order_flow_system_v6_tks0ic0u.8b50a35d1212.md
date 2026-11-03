Calculation: Estimated buy volume = volume × (close − low) / (high − low) when high > low; otherwise volume / 2.
Calculation: Estimated sell volume = volume × (high − close) / (high − low) when high > low; otherwise volume / 2.
Calculation: Bar delta = estimated buy volume − estimated sell volume.
Calculation: Cumulative delta = running sum of bar delta, initialized to zero at the start of the data.
Calculation: Buy percentage = estimated buy volume / volume when volume > 0; otherwise one half.
Calculation: Sell percentage = 1 − buy percentage.
Long: Bar delta >= 0.
Short: Bar delta < 0.
Long: Cumulative delta >= previous bar's cumulative delta.
Short: Cumulative delta < previous bar's cumulative delta.
Long: Cumulative delta >= 0.
Short: Cumulative delta < 0.
Long: Cumulative delta > its EMA.
Short: Cumulative delta <= its EMA.
Long: Cumulative delta crosses above its EMA.
Short: Cumulative delta crosses below its EMA.
Long: Buy percentage >= imbalance threshold.
Short: Sell percentage >= imbalance threshold AND buy percentage < imbalance threshold.
Long: Volume >= SMA of volume × large-print multiplier AND bar delta >= 0.
Short: Volume >= SMA of volume × large-print multiplier AND bar delta < 0.
Long: Bar delta < −abs(SMA of bar delta) AND close >= previous close.
Short: Bar delta > abs(SMA of bar delta) AND close <= previous close.