Calculation: Adjusted volume = volume if volume > 0, otherwise 1.
Calculation: Fair value = rolling sum of adjusted volume × (high + low + close) / 3 divided by rolling sum of adjusted volume.
Calculation: Fair-value dispersion = square root of max(rolling sum of adjusted volume × ((high + low + close) / 3)² divided by rolling sum of adjusted volume minus fair value², 0), using the same lookback as fair value.
Calculation: Volume z-score = (adjusted volume minus its rolling simple moving average) divided by its rolling standard deviation, using the same lookback for both; use 0 if the standard deviation is 0.
Calculation: Upper wick fraction = (high − max(open, close)) / (high − low) if high > low, otherwise 0.
Calculation: Lower wick fraction = (min(open, close) − low) / (high − low) if high > low, otherwise 0.
Calculation: Close location = (close − low) / (high − low) if high > low, otherwise 0.5.
Calculation: Upper stretch = (high − fair value) / fair-value dispersion if fair-value dispersion > 0, otherwise 0.
Calculation: Lower stretch = (fair value − low) / fair-value dispersion if fair-value dispersion > 0, otherwise 0.
Long: Lower stretch >= stretch threshold AND volume z-score >= volume climax threshold AND lower wick fraction >= wick threshold AND close location >= long close-location threshold AND bars since previous long signal > cooldown threshold.
Short: Upper stretch >= stretch threshold AND volume z-score >= volume climax threshold AND upper wick fraction >= wick threshold AND close location <= short close-location threshold AND bars since previous short signal > cooldown threshold.