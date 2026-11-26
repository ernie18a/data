Calculation: h = ColorBulls histogram(applied price, first smoothing method, first lookback, first phase, second smoothing method, second lookback, second phase), calculated on T1 bars using last completed bars
Long: h[signal-bar offset] > h[signal-bar offset + 1] AND h[signal-bar offset + 1] < h[signal-bar offset + 2]
Short: h[signal-bar offset] < h[signal-bar offset + 1] AND h[signal-bar offset + 1] > h[signal-bar offset + 2]
Exit: long, low <= entry price - stop-loss distance in points OR high >= entry price + take-profit distance in points
Exit: short, high >= entry price + stop-loss distance in points OR low <= entry price - take-profit distance in points