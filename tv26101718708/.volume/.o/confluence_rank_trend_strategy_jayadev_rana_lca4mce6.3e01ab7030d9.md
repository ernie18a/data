Calculation: Clamp(x) = x limited to the range 0–1
Calculation: Long score = trend points + momentum points + efficiency points + volatility points + participation points
Calculation: Short score = trend points + momentum points + efficiency points + volatility points + participation points
Calculation: Trend points (long) = 10 if close is above the slow EMA, plus 10 if the fast EMA is above the slow EMA; otherwise each condition contributes 0
Calculation: Trend points (short) = 10 if close is below the slow EMA, plus 10 if the fast EMA is below the slow EMA; otherwise each condition contributes 0. The fast EMA uses a shorter lookback than the slow EMA.
Calculation: Momentum points (long) = 20 × Clamp((RSI − 50) / 20)
Calculation: Momentum points (short) = 20 × Clamp((50 − RSI) / 20)
Calculation: Efficiency ratio = absolute net close change over the lookback divided by the sum of absolute one-bar close changes over that lookback
Calculation: Efficiency points (long) = 20 × Clamp(efficiency ratio / full-points efficiency threshold) if close is above its value one efficiency lookback ago; otherwise 0
Calculation: Efficiency points (short) = 20 × Clamp(efficiency ratio / full-points efficiency threshold) if close is below its value one efficiency lookback ago; otherwise 0
Calculation: Volatility points = 20 × ATR percentile rank / lower percentile threshold if the rank is below the lower threshold; 20 if between the lower and upper thresholds inclusive; otherwise 20 × Clamp((100 − rank) / (100 − upper threshold)
Calculation: Participation points (long) = 10 if average volume is zero; otherwise 20 × Clamp(current volume / average volume − 0.5) if close is above open, and 0 otherwise
Calculation: Participation points (short) = 10 if average volume is zero; otherwise 20 × Clamp(current volume / average volume − 0.5) if close is below open, and 0 otherwise
Long: flat AND more than the greater of the slow EMA lookback and ATR percentile lookback bars have elapsed AND long score ≥ entry threshold AND previous bar's long score < entry threshold
Short: flat AND more than the greater of the slow EMA lookback and ATR percentile lookback bars have elapsed AND short score ≥ entry threshold AND previous bar's short score < entry threshold AND the long-entry condition is false
Exit: long, low ≤ trailing stop OR long score < exit threshold
Exit: short, high ≥ trailing stop OR short score < exit threshold
Calculation: ATR trailing stop for a long position = the greatest of the previous trailing stop and the latest close − ATR multiple × ATR; initial stop = entry signal bar close − ATR multiple × ATR
Calculation: ATR trailing stop for a short position = the least of the previous trailing stop and the latest close + ATR multiple × ATR; initial stop = entry signal bar close + ATR multiple × ATR