Calculation: Trend baseline = EMA of SMA of close, using the same length for both averages.
Calculation: Liquidity levels = divide the range from the lowest (low minus ATR) to the highest (high plus ATR) over a lookback into 26 equal steps; use levels at step indices 0 through 25. Floor the range width at 0.00001.
Calculation: Level volume = sum of volume over the current bar and the preceding lookback bars whose (high + low) / 2 is within half a step of the current liquidity level. The point of control is the first level with the maximum level volume.
Long: close > trend baseline + ATR.
Short: close < trend baseline - ATR.
Long: trend baseline > trend baseline at a prior bar.
Short: trend baseline <= trend baseline at the same prior bar.
Long: there exists a liquidity level where close > the level AND level volume / maximum level volume > the threshold AND (point-of-control highlighting is disabled OR the level is not the point of control).
Short: there exists a liquidity level where close <= the level AND level volume / maximum level volume > the threshold AND (point-of-control highlighting is disabled OR the level is not the point of control).