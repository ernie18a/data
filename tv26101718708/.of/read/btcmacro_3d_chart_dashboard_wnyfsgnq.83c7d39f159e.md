Calculation: Normalized macro oscillator = weighted sum of rolling z-scores of the Pi-cycle ratio (twice the shorter-lookback SMA of close divided by the longer-lookback SMA of close, minus one), MVRV, NUPL, Puell multiple, stock-to-flow, risk wave, log-price deviation from a longer-lookback linear regression of log price, close divided by M2, ISM/PMI, and volume percentage change over a shorter lookback; each input source defaults to close.
Calculation: Smoothed oscillator = short-lookback EMA of the normalized macro oscillator.
Calculation: Upper adaptive band = long-lookback rolling mean of the smoothed oscillator plus a volatility multiple of its long-lookback rolling standard deviation.
Long: Smoothed oscillator < 0
Short: Smoothed oscillator > upper adaptive band