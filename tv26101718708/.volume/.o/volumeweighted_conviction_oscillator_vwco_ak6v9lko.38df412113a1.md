Calculation: CLV = 0 when high = low; otherwise (2 × close − high − low) / (high − low)
Calculation: Volume intensity = volume / SMA(volume, lookback)
Calculation: VWCO = 100 when EMA(buying conviction, lookback) + EMA(selling conviction, lookback) is 0; otherwise 100 × EMA(buying conviction, lookback) / [EMA(buying conviction, lookback) + EMA(selling conviction, lookback)], where conviction score = volume intensity × (high − low) × CLV, buying conviction = max(conviction score, 0), and selling conviction = max(−conviction score, 0). Both EMAs use the same lookback.
Calculation: Signal Line = EMA(VWCO, lookback)
Long: VWCO > 50 OR VWCO crosses above Signal Line
Short: VWCO < 50 OR VWCO crosses below Signal Line