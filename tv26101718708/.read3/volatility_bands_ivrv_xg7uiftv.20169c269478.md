Calculation: anchor = T1 close at the T1 bar horizon bars before the last completed T1 bar, taken on chart bars
Calculation: RV fraction = sqrt(horizon) * RV estimate at the T1 bar horizon bars before the last completed T1 bar, taken on chart bars, where RV estimate is computed on T1 bars as Yang-Zhang volatility(T1 open, high, low, close, lookback), or sample standard deviation(log(T1 close / previous T1 close), lookback), or ATR(T1, ATR length) / T1 close * ATR-to-sigma factor, per the RV estimator parameter
Calculation: IV fraction = implied volatility index close / 100 * sqrt(horizon / bars per year of T1), where the index close is its T1 close at the T1 bar horizon bars before its last completed T1 bar, taken on chart bars
Calculation: scaled move(x) = exp(x) if band geometry selects the exponential form, else 1 + x
Long: close > anchor * scaled move(sigma multiple * RV fraction) AND chart timeframe <= T1
Short: close < anchor * scaled move(-sigma multiple * RV fraction) AND chart timeframe <= T1
Long: close > anchor * scaled move(sigma multiple * IV fraction) AND chart timeframe <= T1
Short: close < anchor * scaled move(-sigma multiple * IV fraction) AND chart timeframe <= T1