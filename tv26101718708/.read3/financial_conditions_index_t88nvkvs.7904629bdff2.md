Calculation: FCI = the weighted mean of four component Z-scores, using a separate weight for each and omitting unavailable components and their weights; each component Z-score = (close - SMA(close, shared lookback, T1, current bar)) / Stdev(close, shared lookback, T1, current bar), calculated on T1 bars including the still-forming bar and mapped to chart bars.
Long: FCI < -status band
Short: FCI > status band
Calculation: Financial conditions index = weighted mean of available rolling z-scores of 10-year real yield, high-yield credit spread, US dollar index, and equity volatility, using separate weights P3, P4, P5, and P6; each rolling z-score = (value - SMA(value, P1)) / StDev(value, P1) on T1; exclude unavailable values and their weights.
Long: Financial conditions index < -P2
Short: Financial conditions index > P2