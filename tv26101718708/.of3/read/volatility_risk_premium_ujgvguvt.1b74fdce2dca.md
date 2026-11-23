Calculation: VRP = EMA(VIX close - Realized Volatility(S&P 500 price OHLC, realized-volatility lookback, selected method), smoothing)
Calculation: VRP Z-score = (VRP - SMA(VRP, statistical lookback)) / max(STDEV(VRP, statistical lookback), minimum standard deviation)
Long: VRP Z-score <= -Z-score threshold AND VRP > nz(VRP[1], 0)
Short: VRP Z-score >= Z-score threshold AND VRP < nz(VRP[1], 0)