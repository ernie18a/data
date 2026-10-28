Calculation: Fast stochastic = SMA of the standard stochastic oscillator; slow stochastic = SMA of fast stochastic using a second smoothing lookback.
Calculation: Reversal state = 1 when close two bars ago < prior close AND current close > prior close AND fast stochastic < slow stochastic AND fast stochastic > a threshold; -1 when close two bars ago > prior close AND current close < prior close AND fast stochastic > slow stochastic AND fast stochastic < the threshold; otherwise retain the previous state.
Calculation: Market facilitation state = 1 when (high - low) / volume × 10000 > an upper threshold; -1 when it is < a lower threshold; otherwise retain the previous state.
Long: Reversal state = 1 AND market facilitation state = 1
Short: Reversal state = -1 AND market facilitation state = -1
Exit: any, (Reversal state ≠ 1 OR market facilitation state ≠ 1) AND (Reversal state ≠ -1 OR market facilitation state ≠ -1)