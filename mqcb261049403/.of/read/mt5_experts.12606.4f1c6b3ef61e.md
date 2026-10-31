Calculation: Volume-weighted price = sum(volume × weighted close) / max(sum(volume), 1) over a rolling lookback, where weighted close = (high + low + 2 × close) / 4.
Calculation: Normalized price = 100 × (volume-weighted price − rolling minimum of volume-weighted price) / max(rolling maximum − rolling minimum of volume-weighted price, minimum price increment) − 50, using the same extrema lookback for minimum and maximum.
Calculation: First average = simple moving average of normalized price; second average = simple moving average of the first average using the same smoothing lookback. Calculate both on the chart timeframe or on a higher timeframe using its last completed bar.
Long: First average > second average AND previous first average <= previous second average.
Short: First average <= second average AND previous first average > previous second average.
Exit: long, first average <= second average OR low <= entry price − stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, first average > second average OR high >= entry price + stop-loss distance OR low <= entry price − take-profit distance.