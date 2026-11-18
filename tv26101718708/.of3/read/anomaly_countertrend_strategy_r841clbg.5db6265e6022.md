Calculation: Percent change = 100 * (chart-bar close - close[lookback - 1, T1, last completed bar]) / close[lookback - 1, T1, last completed bar]
Long: Percent change <= -threshold AND position is flat or short
Short: Percent change >= threshold AND position is flat or long
Exit: long, low <= entry price - stop-loss distance in ticks OR high >= entry price + take-profit distance in ticks
Exit: short, high >= entry price + stop-loss distance in ticks OR low <= entry price - take-profit distance in ticks