Calculation: Normalized volatility = rolling standard deviation of (close − rolling lowest low) / (rolling highest high − rolling lowest low).
Calculation: Upper/lower volatility series = (bars-ago offset of the highest/lowest normalized volatility over the box-detection lookback + that lookback) / that lookback.
Calculation: Channel bounds = highest high and lowest low since the most recent lower-series crossover above the upper series; freeze these bounds when the upper series crosses above the lower series after the minimum formation duration, subject to the overlap setting.
Calculation: Breakout price = close in weak-close mode or the open-close midpoint in strong-close mode.
Long: Active channel AND breakout price > channel upper bound
Short: Active channel AND breakout price < channel lower bound