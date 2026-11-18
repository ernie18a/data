Calculation: T1 buy volume = on each chart bar, sum over its T1 bars of volume * (close - low) / (high - low) when high > low, otherwise 0; include the still-forming T1 bar when present
Calculation: T1 sell volume = on each chart bar, sum over its T1 bars of volume * (high - close) / (high - low) when high > low, otherwise 0; include the still-forming T1 bar when present
Calculation: Order pressure = 100 * (T1 buy volume - T1 sell volume) / (T1 buy volume + T1 sell volume), or 0 when the denominator is 0; evaluated on chart bars
Calculation: Relative volume = the sum of volume over T1 bars in the current chart bar / SMA of that chart-bar volume series (relative-volume lookback); include the still-forming T1 bar when present
Calculation: CVD = cumulative sum on chart bars of T1 buy volume - T1 sell volume, starting at 0; include the still-forming T1 bar when present
Long: Relative volume > big-volume multiplier AND Order pressure > pressure threshold
Short: Relative volume > big-volume multiplier AND Order pressure < -pressure threshold
Long: Relative volume > absorption relative-volume threshold AND Order pressure < -absorption pressure threshold AND abs(close - open) < ATR(ATR lookback) * ATR multiplier
Short: Relative volume > absorption relative-volume threshold AND Order pressure > absorption pressure threshold AND abs(close - open) < ATR(ATR lookback) * ATR multiplier
Long: low < low[divergence lookback] AND CVD > CVD[divergence lookback]
Short: high > high[divergence lookback] AND CVD < CVD[divergence lookback]
Short: Order pressure > exhaustion pressure threshold AND high - low < ATR(ATR lookback) * ATR multiplier
Long: Order pressure < -exhaustion pressure threshold AND high - low < ATR(ATR lookback) * ATR multiplier
Short: high > prior chart bar high AND close < prior chart bar high
Long: low < prior chart bar low AND close > prior chart bar low