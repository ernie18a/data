Calculation: Volatility-quality increment = abs(0.5 × ((C − Cₛ) / max(H − L, H − Cₛ, Cₛ − L) + (C − O) / (H − L))) × (0.5 × ((C − Cₛ) + (C − O))); O, H, L, and C are same-length, same-method moving averages of open, high, low, and close on the chart timeframe; Cₛ is the close moving average from the smoothing lookback bars earlier.
Calculation: Volatility-quality line = prior bar's line plus the increment, except when the absolute increment is below the filter threshold (filter parameter × minimum price increment), in which case it equals the prior bar's line.
Calculation: Line direction = sign of the current line minus the prior bar's line; when the difference is zero, retain the prior nonzero direction.
Long: Line direction on the last completed chart-timeframe bar = +1 AND line direction on the preceding bar = −1
Short: Line direction on the last completed chart-timeframe bar = −1 AND line direction on the preceding bar = +1
Exit: long, Line direction on the last completed chart-timeframe bar = −1 AND line direction on the preceding bar = +1
Exit: short, Line direction on the last completed chart-timeframe bar = +1 AND line direction on the preceding bar = −1