Calculation: Detrended ELI = Ehlers Leading Indicator(HL2, ELI length) - EMA(Ehlers Leading Indicator(HL2, ELI length), ELI length), calculated on chart bars using T1 HL2 values from the still-forming T1 bar
Calculation: ELI direction = 1 when Detrended ELI > 0, -1 when Detrended ELI < 0, otherwise its previous value, initially 0
Calculation: Smoothed fast stochastic = SMA(Stochastic(close, high, low, reversal stochastic lookback), K smoothing)
Calculation: Reversal direction = 1 when close[earlier reversal lag] < close[recent reversal lag] AND close > close[recent reversal lag] AND Smoothed fast stochastic < SMA(Smoothed fast stochastic, D smoothing) AND Smoothed fast stochastic > reversal level; -1 when close[earlier reversal lag] > close[recent reversal lag] AND close < close[recent reversal lag] AND Smoothed fast stochastic > SMA(Smoothed fast stochastic, D smoothing) AND Smoothed fast stochastic < reversal level; otherwise its previous value, initially 0
Long: close on T1 bars > close[shorter price-rise lag] AND close[shorter price-rise lag] > close[longer price-rise lag] AND Slow Stochastic(close, high, low, standalone stochastic lookback) on T1 bars using the still-forming T1 bar < standalone stochastic threshold
Short: close on T1 bars < close[shorter price-fall lag] AND close[shorter price-fall lag] < close[longer price-fall lag] AND Fast Stochastic(close, high, low, standalone stochastic lookback) on T1 bars using the still-forming T1 bar > standalone stochastic threshold
Long: Detrended ELI crosses above 0
Short: Detrended ELI crosses below 0
Long: (reverse-trade parameter is false AND Reversal direction = 1 AND ELI direction = 1) OR (reverse-trade parameter is true AND Reversal direction = -1 AND ELI direction = -1)
Short: (reverse-trade parameter is false AND Reversal direction = -1 AND ELI direction = -1) OR (reverse-trade parameter is true AND Reversal direction = 1 AND ELI direction = 1)
Exit: long, Reversal direction and ELI direction do not share the same nonzero sign
Exit: short, Reversal direction and ELI direction do not share the same nonzero sign