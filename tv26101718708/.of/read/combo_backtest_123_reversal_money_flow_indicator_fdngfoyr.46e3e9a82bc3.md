Calculation: Smoothed stochastic = SMA of stochastic %K over the smoothing lookback; stochastic %K = 100 × (close − lowest low over its lookback) / (highest high over its lookback − lowest low over its lookback)
Calculation: Slow smoothed stochastic = SMA of smoothed stochastic over a longer lookback
Calculation: 123 reversal state = 1 when close two bars ago < close one bar ago AND close > close one bar ago AND smoothed stochastic < slow smoothed stochastic AND smoothed stochastic > the threshold; −1 when close two bars ago > close one bar ago AND close < close one bar ago AND smoothed stochastic > slow smoothed stochastic AND smoothed stochastic < the threshold; otherwise retain the prior state, initially 0
Calculation: Money flow state = 1 when the longer-lookback EMA of the longer-lookback sum of ((close − open) / (high − low) × volume), included only when (high − low) × volume > 0, minus the shorter-lookback EMA of the shorter-lookback sum of the same values is > 0; −1 when that difference is < 0; otherwise retain the prior state, initially 0
Long: 123 reversal state = 1 AND money flow state = 1
Short: 123 reversal state = −1 AND money flow state = −1
Exit: long, 123 reversal state ≠ 1 OR money flow state ≠ 1
Exit: short, 123 reversal state ≠ −1 OR money flow state ≠ −1