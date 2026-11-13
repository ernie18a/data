Calculation: STC = Wilder-smoothed RSI of the MACD line, where MACD line = EMA(price, fast period) - EMA(price, slow period), and the fast period is shorter than the slow period. It can optionally be computed on a higher timeframe than the chart, using the still-forming higher-timeframe bar for each chart bar.
Long: STC(current bar) > STC(previous bar)
Short: STC(current bar) < STC(previous bar)