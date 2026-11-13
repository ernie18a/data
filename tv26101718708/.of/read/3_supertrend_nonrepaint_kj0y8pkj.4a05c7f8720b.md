Calculation: Supertrend = standard ATR-band Supertrend (bands at (high+low)/2 +/- factor*ATR, direction up when close is above the trailing lower band, down when below the trailing upper band); the fast Supertrend has a shorter ATR length and a smaller factor than the mid Supertrend; both are on the chart timeframe and use completed bars
Calculation: TrendStrength = abs(close - EMA(close, medium lookback)) / ATR(lookback)
Calculation: VolRatio = volume / SMA(volume, lookback)
Long: (fast Supertrend is up AND mid Supertrend is up) AND NOT (fast Supertrend was up AND mid Supertrend was up on the previous bar) AND TrendStrength > trend threshold AND (optional filter) VolRatio >= high-volume threshold AND (optional filter) bar time-of-day is inside the London or New York session window
Long: fast Supertrend is up AND mid Supertrend is up (bullish state)
Long: low > high 2 bars earlier (bullish fair value gap, on a completed bar)
Short: (fast Supertrend is down AND mid Supertrend is down) AND NOT (fast Supertrend was down AND mid Supertrend was down on the previous bar) AND TrendStrength > trend threshold AND (optional filter) VolRatio >= high-volume threshold AND (optional filter) bar time-of-day is inside the London or New York session window
Short: fast Supertrend is down AND mid Supertrend is down (bearish state)
Short: high < low 2 bars earlier (bearish fair value gap, on a completed bar)