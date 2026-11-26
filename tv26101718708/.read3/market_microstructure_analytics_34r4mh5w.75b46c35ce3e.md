Calculation: Tick direction = sign of the latest nonzero close change, carried forward; initialize positive.
Calculation: Robust z-score(x, lookback) = (x − rolling median(x, lookback)) / (1.4826 × rolling median(abs(x − rolling median(x, lookback)), lookback)); return zero when the denominator is at most the robust-z floor.
Calculation: Effective spread = SMA(if close > 0 and high > low then 2 × tick direction × (close − (high + low)/2) / close × 100 else 0, estimation lookback).
Calculation: Kyle lambda = EMA(if Var(tick direction × volume, estimation lookback) > variance floor then Cov(close − close[1], tick direction × volume, estimation lookback) / Var(tick direction × volume, estimation lookback) else 0, smoothing lookback).
Calculation: Composite spread = the renormalized capped inverse-variance weighted mean of EMA(Roll spread estimate, smoothing lookback), EMA(Corwin-Schultz spread estimate, smoothing lookback), and EMA(Abdi-Ranaldo spread estimate, smoothing lookback); omit inactive estimates. Each raw-estimate variance is (1.4826 × rolling median absolute deviation over the estimation lookback)^2. Add a regularizer equal to the regularization fraction times the sum of active variances divided by the active estimate count, or the variance floor if that sum is zero, before taking inverse variances. Normalize the inverse variances, cap each weight at the maximum-weight parameter, then renormalize. Corwin-Schultz is active when current and prior bars have positive high and low and high > low. Abdi-Ranaldo is active when the current bar is valid and valid paired bars in the estimation lookback meet the greater of the minimum-pair-count parameter and the ceiling of the minimum-pair-fraction parameter times the estimation lookback.
Calculation: Amihud illiquidity = SMA(abs(log(close / close[1])) / (close × volume), estimation lookback).
Calculation: Liquidity stress index = the mean of Robust z-score(Composite spread, regime lookback), Robust z-score(Amihud illiquidity, regime lookback), and Robust z-score(abs(Kyle lambda), regime lookback), each clipped to plus or minus the winsorization cap.
Long: Robust z-score(Composite spread, regime lookback) <= 0.
Long: Corwin-Schultz estimate is inactive OR EMA(Corwin-Schultz spread estimate, smoothing lookback) <= EMA(Roll spread estimate, smoothing lookback).
Long: Abdi-Ranaldo estimate is inactive OR EMA(Abdi-Ranaldo spread estimate, smoothing lookback) <= EMA(Roll spread estimate, smoothing lookback).
Long: Effective spread <= rolling median(Composite spread, regime lookback).
Long: Robust z-score(abs(Kyle lambda), regime lookback) <= adverse-selection threshold.
Long: Liquidity stress index <= negative compressed threshold.
Long: EMA(Composite spread, shorter trend lookback) <= EMA(Composite spread, longer trend lookback).
Short: Robust z-score(Composite spread, regime lookback) > 0.
Short: Corwin-Schultz estimate is active AND EMA(Corwin-Schultz spread estimate, smoothing lookback) > EMA(Roll spread estimate, smoothing lookback).
Short: Abdi-Ranaldo estimate is active AND EMA(Abdi-Ranaldo spread estimate, smoothing lookback) > EMA(Roll spread estimate, smoothing lookback).
Short: Effective spread > rolling median(Composite spread, regime lookback).
Short: Robust z-score(Amihud illiquidity, regime lookback) > Amihud threshold.
Short: Robust z-score(abs(Kyle lambda), regime lookback) > adverse-selection threshold.
Short: Liquidity stress index >= stress threshold OR Liquidity stress index >= elevated threshold.
Short: EMA(Composite spread, shorter trend lookback) > EMA(Composite spread, longer trend lookback).