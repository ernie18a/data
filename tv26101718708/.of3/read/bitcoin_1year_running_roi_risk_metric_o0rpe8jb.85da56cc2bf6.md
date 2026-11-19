Calculation: Selected top curve = log-top coefficient × ln(chart-bar open time − anchor timestamp + log-top time offset) + log-top intercept when top-fit mode is logarithmic; otherwise linear-top slope × (chart-bar open time − anchor timestamp) + linear-top intercept
Calculation: Bottom curve = bottom slope × (chart-bar open time − anchor timestamp) + bottom intercept
Calculation: Normalized log return = (ln(close(T1, current bar still forming in realtime) / close(T1, T1 lookback bars ago)) − Bottom curve) / (Selected top curve − Bottom curve), evaluated on chart bars using T1 values
Long: Normalized log return ≤ buy-zone level
Short: Normalized log return ≥ sell-zone level