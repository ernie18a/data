Calculation: Fast = MA(RSI(close, RSI lookback, T1, bar still forming), shorter lookback, smoothing method, phase) on T1 bars, sampled onto chart bars
Calculation: Slow = MA(Fast, longer lookback, same smoothing method, same phase) on T1 bars, sampled onto chart bars
Calculation: Prior direction = long if Fast > Slow, short if Fast < Slow on the most recent earlier T1 bar where they differ
Long: Fast > Slow OR (Fast = Slow AND Prior direction is long)
Short: Fast < Slow OR (Fast = Slow AND Prior direction is short)