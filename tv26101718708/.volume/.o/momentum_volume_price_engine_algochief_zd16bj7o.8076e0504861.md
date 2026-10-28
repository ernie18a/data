Calculation: Up-close count = number of closes higher than the preceding close across the momentum lookback.
Calculation: Down-close count = number of closes lower than the preceding close across the same momentum lookback.
Calculation: Volume change (%) = (average volume over the momentum lookback − 50-bar average volume) / 50-bar average volume × 100.
Calculation: Price change (%) = (current close − close at the momentum lookback’s start) / close at the momentum lookback’s start × 100.
Calculation: Long stop price = entry price − ATR on the entry bar × stop-distance multiplier.
Calculation: Short stop price = entry price + ATR on the entry bar × stop-distance multiplier.
Long: Up-close count ≥ momentum threshold AND volume change ≥ volume threshold AND price change ≥ positive price threshold
Short: Down-close count ≥ momentum threshold AND volume change ≥ volume threshold AND price change ≤ negative price threshold
Exit: Long, low ≤ long stop price
Exit: Short, high ≥ short stop price