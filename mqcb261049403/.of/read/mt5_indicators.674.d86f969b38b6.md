Calculation: Typical price = (high + low + close) / 3
Calculation: XCCX = 100 × smoothed deviation / smoothed absolute deviation, using the same shorter lookback for both; deviation = typical price − its smoother using a longer lookback; use 0 when deviation is 0
Calculation: Fast step line = a step line from XCCX using the fast step size: set trend up when XCCX exceeds the previous upper band and down when it falls below the previous lower band; in an up trend, the lower band cannot decrease, and in a down trend, the upper band cannot increase; line = lower band + fast step size when up, otherwise upper band − fast step size
Calculation: Slow step line = the same step-line calculation using a larger step size than the fast step size
Long: On the configured higher timeframe, fast step line ≥ slow step line (latest signal uses the still-forming bar)
Short: On the configured higher timeframe, fast step line < slow step line (latest signal uses the still-forming bar)