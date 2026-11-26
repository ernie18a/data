Calculation: pair bid spread = first pair member bid − second pair member bid
Calculation: volatility ceiling = divergence threshold × volatility multiplier
Long: pair bid spread > divergence threshold AND neither pair member has an open position
Short: pair bid spread < −divergence threshold AND neither pair member has an open position AND ATR(first pair member, ATR lookback, T1, bar still forming, evaluated on each tick) ≤ volatility ceiling AND ATR(second pair member, ATR lookback, T1, bar still forming, evaluated on each tick) ≤ volatility ceiling