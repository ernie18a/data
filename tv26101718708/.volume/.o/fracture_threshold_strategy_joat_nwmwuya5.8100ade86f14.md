Calculation: Bull alignment score = count of: fast EMA > short EMA; RSI > 50; close > medium EMA; medium EMA > medium SMA; medium SMA > intermediate EMA; intermediate EMA > longer EMA; close > long-term EMA. Bear alignment score = count of the corresponding reversed comparisons.
Calculation: Smoothed relative volume = EMA of (short-lookback SMA of volume / max(long-lookback SMA of volume, 1)); the long lookback is longer than the short lookback.
Calculation: Long stop = entry price − ATR at entry × configured stop multiplier
Calculation: Long target = entry price + (entry price − long stop) × configured reward-to-risk ratio
Calculation: Short stop = entry price + ATR at entry × configured stop multiplier
Calculation: Short target = entry price − (short stop − entry price) × configured reward-to-risk ratio
Long: EMA crossover trigger is enabled and fast EMA crosses above short EMA, or crossover trigger is disabled and fast EMA changes from not above to above short EMA; bull alignment score ≥ configured minimum; smoothed relative volume ≥ configured minimum; bar time is within an enabled London or New York session in the configured timezone; position side = flat
Short: EMA crossover trigger is enabled and fast EMA crosses below short EMA, or crossover trigger is disabled and fast EMA changes from not below to below short EMA; bear alignment score ≥ configured minimum; smoothed relative volume ≥ configured minimum; bar time is within an enabled London or New York session in the configured timezone; position side = flat
Exit: long, low ≤ long stop OR high ≥ long target
Exit: short, high ≥ short stop OR low ≤ short target