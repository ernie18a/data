Calculation: Williams Vix Fix = (highest close over lookback − current low) / highest close over lookback × 100
Calculation: Williams Vix Fix upper band = SMA(Williams Vix Fix, lookback) + multiplier × standard deviation(Williams Vix Fix, same lookback)
Calculation: Williams Vix Fix percentile threshold = highest Williams Vix Fix over lookback × percentile factor
Calculation: Weighted K = arithmetic mean of the K values of all enabled components: stochastic of close/high/low; stochastic of RSI; RSI; stochastic of smoothed signed volume; and stochastic of smoothed percent change
Calculation: D = moving average of Weighted K
Calculation: StochCCI = 100 × WMA((CCI(hlc3, lookback) − lowest of that CCI over lookback) / (highest CCI(close, same lookback) − lowest CCI(close, same lookback)), smoothing length), treating an undefined ratio as zero
Long: (low > previous low AND close > previous high AND close > close from the longer of two lookbacks ago OR close < close from the shorter of two lookbacks ago) AND close > close from the entry-strength lookback ago AND (previous Williams Vix Fix ≥ previous upper band OR previous Williams Vix Fix ≥ previous percentile threshold) AND current Williams Vix Fix < current upper band AND current Williams Vix Fix < current percentile threshold
Long: close > previous close AND close > previous open AND close > close from the entry-strength lookback ago AND (close < close from the longer of two lookbacks ago OR close < close from the shorter of two lookbacks ago) AND (previous Williams Vix Fix ≥ previous upper band OR previous Williams Vix Fix ≥ previous percentile threshold) AND (current Williams Vix Fix ≥ current upper band OR current Williams Vix Fix ≥ current percentile threshold)
Long: StochCCI crosses above its prior-bar value AND StochCCI < 50
Short: StochCCI crosses below its prior-bar value AND StochCCI > 50
Exit: Long, previous Weighted K ≥ previous D AND current Weighted K < current D AND current D > 80