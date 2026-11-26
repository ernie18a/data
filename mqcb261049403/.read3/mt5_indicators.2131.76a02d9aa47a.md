Calculation: Fast rate = fractional change from the prior bar of moving average(selected applied price, selected smoothing method, shorter lookback, phase)
Calculation: Slow rate = fractional change from the prior bar of moving average(selected applied price, selected smoothing method, longer lookback, phase)
Long: Fast rate > Slow rate
Short: Fast rate < Slow rate
Long: Fast rate > 0 AND Fast rate != Fast rate[previous bar]
Short: Fast rate < 0 AND Fast rate != Fast rate[previous bar]
Long: Fast rate > Slow rate on T1 still-forming bars, calculated on T1 bars and mapped to chart bars
Short: Fast rate < Slow rate on T1 still-forming bars, calculated on T1 bars and mapped to chart bars
Long: Fast rate > 0 AND Fast rate != Fast rate[previous bar] on T1 still-forming bars, calculated on T1 bars and mapped to chart bars
Short: Fast rate < 0 AND Fast rate != Fast rate[previous bar] on T1 still-forming bars, calculated on T1 bars and mapped to chart bars