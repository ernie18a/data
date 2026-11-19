Calculation: Futures composite(T) = shared first/second-feed weight × futures feed 1 close(T, current/forming bar) + shared first/second-feed weight × futures feed 2 close(T, current/forming bar) + third-feed weight × futures feed 3 close(T, current/forming bar), sampled on chart bars
Calculation: Spot composite(T) = shared first/second-feed weight × spot feed 1 close(T, current/forming bar) + shared first/second-feed weight × spot feed 2 close(T, current/forming bar) + third-feed weight × spot feed 3 close(T, current/forming bar), sampled on chart bars
Calculation: Spread(T) = Futures composite(T) − Spot composite(T)
Calculation: Z(T) = (Spread(T) − SMA(Spread(T), lookback)) / STDEV(Spread(T), lookback), calculated on chart bars using current/forming T-bar values
Long: long entries enabled AND Z(T1) > long-entry threshold AND Z(T2) > long-entry threshold AND Z(T3) > long-entry threshold
Short: short entries enabled AND Z(T1) < short-entry threshold AND Z(T2) < short-entry threshold AND Z(T3) < short-entry threshold
Exit: long, hold-duration exit enabled AND current chart-bar datetime ≥ most recent qualifying long-signal datetime + hold-duration parameter
Exit: short, hold-duration exit enabled AND current chart-bar datetime ≥ most recent qualifying short-signal datetime + hold-duration parameter
Exit: long, take-profit exit enabled AND high ≥ entry price × (1 + take-profit percentage / 100)
Exit: long, stop-loss exit enabled AND low ≤ entry price × (1 − stop-loss percentage / 100)
Exit: short, take-profit exit enabled AND low ≤ entry price × (1 − take-profit percentage / 100)
Exit: short, stop-loss exit enabled AND high ≥ entry price × (1 + stop-loss percentage / 100)