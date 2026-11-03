Calculation: Delta = sum of lower-timeframe volume multiplied by the sign of each lower-timeframe bar’s close minus its previous close; use lower-timeframe bars within the current chart bar, including the bar still forming
Calculation: Expected move = linear regression estimate of price movement in ticks from Delta, using the correlation, standard deviations, and averages of the previous 100 completed chart bars
Calculation: Inefficiency z-score = z-score of sign(Expected move) × (Expected move − actual chart-bar movement in ticks), standardized against the current and previous 99 chart bars
Long: Inefficiency z-score ≥ 2 AND Expected move < 0
Short: Inefficiency z-score ≥ 2 AND Expected move > 0