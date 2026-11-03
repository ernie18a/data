Calculation: Bullish MasterTrend score = count of: short EMA > shorter EMA; RSI > 50; close > EMA; EMA > SMA; SMA > EMA; EMA > EMA; close > long-term EMA, using the strategy’s progressively longer trend lookbacks
Calculation: Bearish MasterTrend score = count of the corresponding seven conditions with each comparison reversed
Calculation: Relative volume ratio = EMA of short-lookback volume SMA divided by the greater of long-lookback volume SMA and 1; short lookback is shorter than long lookback
Calculation: Stop distance = ATR on the signal bar × configurable multiplier
Calculation: Long stop = signal-bar close − stop distance; long target = signal-bar close + stop distance × configurable reward-to-risk ratio
Calculation: Short stop = signal-bar close + stop distance; short target = signal-bar close − stop distance × configurable reward-to-risk ratio
Long: Current bar is complete AND EMA4 > EMA5 AND previous EMA4 ≤ previous EMA5 AND bullish MasterTrend score ≥ configurable minimum AND relative volume ratio ≥ configurable minimum AND session filter is disabled or an enabled London/New York session is active AND position is flat
Short: Current bar is complete AND EMA4 < EMA5 AND previous EMA4 ≥ previous EMA5 AND bearish MasterTrend score ≥ configurable minimum AND relative volume ratio ≥ configurable minimum AND session filter is disabled or an enabled London/New York session is active AND position is flat
Exit: Long, low ≤ long stop OR high ≥ long target
Exit: Short, high ≥ short stop OR low ≤ short target