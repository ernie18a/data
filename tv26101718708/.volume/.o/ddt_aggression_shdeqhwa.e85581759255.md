Calculation: Volume delta = current chart bar’s volume delta, aggregated from lower-timeframe bars
Calculation: Average positive delta = sum of positive volume deltas over the lookback / count of positive-delta bars over the lookback, using 1 if the count is zero
Calculation: Average negative delta = sum of absolute negative volume deltas over the lookback / count of negative-delta bars over the lookback, using 1 if the count is zero
Long: volume delta > 0 AND volume delta >= average positive delta * multiplier
Short: volume delta < 0 AND absolute volume delta >= average negative delta * multiplier