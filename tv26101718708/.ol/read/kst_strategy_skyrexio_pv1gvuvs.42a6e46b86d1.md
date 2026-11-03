Calculation: KST = SMA(ROC(close, short lookback), its smoothing lookback) + 2 × SMA(ROC(close, next-longer lookback), its smoothing lookback) + 3 × SMA(ROC(close, next-longer lookback), its smoothing lookback) + 4 × SMA(ROC(close, longest lookback), its smoothing lookback); ROC = 100 × (close − close N bars ago) / close N bars ago
Calculation: KST signal line = SMA(KST, signal lookback)
Calculation: Alligator jaw = 13-period smoothed moving average of (high + low) / 2, using the value from 8 bars earlier
Calculation: Choppiness Index = 100 × log10(sum of 1-period ATR over the lookback / (highest high − lowest low over the lookback)) / log10(lookback)
Calculation: Filtering moving average = selected moving average of close over a long-term lookback
Long: KST crosses above its signal line AND close > Alligator jaw AND close > filtering moving average AND (Choppiness Index filter is disabled OR Choppiness Index < threshold)
Exit: Long, high >= entry-bar close + take-profit ATR multiple × ATR on the entry bar OR low <= entry-bar low − stop-loss ATR multiple × ATR on the entry bar