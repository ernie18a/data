Calculation: Weighted buying volume = volume × abs(close − open) / (high − low) when close > open and high > low; otherwise 0.
Calculation: Weighted selling volume = volume × abs(close − open) / (high − low) when close < open and high > low; otherwise 0.
Calculation: Buying dominance = EMA of the lookback sum of weighted buying volume divided by max(1, the lookback sum of weighted buying and selling volume), using the same lookback for both sums; use the raw ratio when smoothing is disabled.
Calculation: Buy-flip eligibility = initially true; reset to true when buying dominance <= 0.5; set to false after a buy flip.
Calculation: Sell-flip eligibility = initially true; reset to true when buying dominance >= 0.5; set to false after a sell flip.
Long: Buying dominance > dominance threshold.
Short: Buying dominance < 1 − dominance threshold.
Long: Previous bar's buying dominance > dominance threshold.
Short: Previous bar's buying dominance < 1 − dominance threshold.
Long: Buying dominance > dominance threshold AND previous bar's buying dominance <= dominance threshold AND buy-flip eligibility = true.
Short: Buying dominance < 1 − dominance threshold AND previous bar's buying dominance >= 1 − dominance threshold AND sell-flip eligibility = true.
Long: Buying dominance > extreme threshold AND previous bar's buying dominance <= extreme threshold.
Short: Buying dominance < 1 − extreme threshold AND previous bar's buying dominance >= 1 − extreme threshold.