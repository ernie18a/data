Calculation: Smoothed midpoint = EMA(VWMA(highest high over lookback, lookback) and VWMA(lowest low over lookback, lookback), lookback), averaged
Calculation: Volume-weighted midpoint = VWMA(smoothed midpoint × (volume / VWMA(volume, lookback)), 3)
Calculation: RSI zone adjustment = RSI(volume-weighted midpoint, lookback) × 0.01 × SMA(highest-highest? )
Calculation: Zone width = RSI(volume-weighted midpoint, lookback) × 0.01 × SMA(VWMA(highest high over lookback, lookback) − VWMA(lowest low over lookback, lookback), lookback)
Calculation: Upper zone = smoothed midpoint + zone width
Calculation: Lower zone = smoothed midpoint − zone width
Calculation: Basis = average of upper and lower zones
Calculation: Upper stop = upper zone × (1 + stop percentage)
Calculation: Lower stop = lower zone × (1 − stop percentage)
Long: Purchase source crosses above lower zone AND long entry is available; rearm after purchase source crosses below upper zone, or when the configured reset condition occurs
Short: Purchase source crosses below upper zone AND short entry is available; rearm after purchase source crosses above lower zone, or when the configured reset condition occurs
Exit: Long, exit source crosses above upper zone OR exit source crosses below lower stop OR (exit source previously crossed above basis since entry and now crosses below basis)
Exit: Short, exit source crosses below lower zone OR exit source crosses above upper stop OR (exit source previously crossed below basis since entry and now crosses above basis)