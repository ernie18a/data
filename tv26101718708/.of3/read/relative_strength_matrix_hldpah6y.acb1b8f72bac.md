Calculation: Relative-strength score(target) = 100 × sum over four increasing lookbacks i of (weight_i × target T1 close / target T1 close[min(available chart bars, lookback_i) chart bars ago]) divided by sum over the same lookbacks of (weight_i × S&P 500 index T1 close / S&P 500 index T1 close[min(available chart bars, lookback_i) chart bars ago]); each lookback has its own weight; evaluated on chart bars using T1 values, including the current T1 bar, which may still be forming.
Calculation: Mapped tracking ETF return over lookback n = current T1 close / T1 close[n T1 bars ago] − 1; evaluated on chart bars using T1 values, including the current T1 bar, which may still be forming.
Calculation: Mapped tracking ETF current-bar return = (T1 close − T1 open) / T1 open; evaluated on chart bars using the current T1 bar, which may still be forming.
Long: round(IBD Relative Strength Rating(Relative-strength score(traded instrument), seed relative-strength rating curve), 0) >= upper strength-rating threshold
Short: round(IBD Relative Strength Rating(Relative-strength score(traded instrument), seed relative-strength rating curve), 0) <= lower strength-rating threshold
Long: round(IBD Relative Strength Rating(Relative-strength score(mapped group, industry, or sector ETF), seed relative-strength rating curve), 0) >= upper strength-rating threshold
Short: round(IBD Relative Strength Rating(Relative-strength score(mapped group, industry, or sector ETF), seed relative-strength rating curve), 0) <= lower strength-rating threshold
Long: Mapped tracking ETF current-bar return >= zero-performance threshold
Short: Mapped tracking ETF current-bar return < zero-performance threshold
Long: Mapped tracking ETF return over shortest lookback >= zero-performance threshold
Short: Mapped tracking ETF return over shortest lookback < zero-performance threshold
Long: Mapped tracking ETF return over second-shortest lookback >= zero-performance threshold
Short: Mapped tracking ETF return over second-shortest lookback < zero-performance threshold
Long: Mapped tracking ETF return over second-longest lookback >= zero-performance threshold
Short: Mapped tracking ETF return over second-longest lookback < zero-performance threshold
Long: Mapped tracking ETF return over longest lookback >= zero-performance threshold
Short: Mapped tracking ETF return over longest lookback < zero-performance threshold