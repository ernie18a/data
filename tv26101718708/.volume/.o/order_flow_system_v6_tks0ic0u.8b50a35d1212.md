Calculation: Estimated buy volume = volume × (close − low) / (high − low); if high = low, use volume / 2
Calculation: Estimated sell volume = volume × (high − close) / (high − low); if high = low, use volume / 2
Calculation: Bar delta = estimated buy volume − estimated sell volume
Calculation: Cumulative delta = running sum of bar delta across bars
Long: Bar delta > 0 AND volume >= its lookback average × configurable large-print multiplier
Long: Estimated buy volume / volume >= configurable imbalance threshold
Long: Bar delta < −abs(its shorter-lookback average) AND close >= previous close
Long: Cumulative delta crosses above its EMA
Short: Bar delta < 0 AND volume >= its lookback average × configurable large-print multiplier
Short: Estimated sell volume / volume >= configurable imbalance threshold
Short: Bar delta > abs(its shorter-lookback average) AND close <= previous close
Short: Cumulative delta crosses below its EMA