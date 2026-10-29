Calculation: Smoothed range = Hull moving average of high − low, using a lookback.
Calculation: Adaptive factor = base factor × ATR / average ATR, clamped between minimum and maximum factors; average ATR uses a longer lookback than ATR.
Calculation: Raw upper/lower bands = (high + low + 2 × close) / 4 ± adaptive factor × max(smoothed range, minimum price increment).
Calculation: Trailing upper band = raw upper band if it is below the prior trailing upper band or the prior close is above that prior band; otherwise use the prior trailing upper band. Trailing lower band = raw lower band if it is above the prior trailing lower band or the prior close is below that prior band; otherwise use the prior trailing lower band.
Long: Current bar is confirmed AND prior trend direction is down AND close > trailing upper band.
Short: Current bar is confirmed AND prior trend direction is up AND close < trailing lower band.