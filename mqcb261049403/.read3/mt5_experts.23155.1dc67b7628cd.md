Long: on chart ticks, close(T1, still-forming bar) > high(T1, last completed bar) AND no open position
Short: on chart ticks, close(T1, still-forming bar) < low(T1, last completed bar) AND no open position
Exit: long, stop-loss distance is nonzero AND low <= entry price - stop-loss distance OR take-profit distance is nonzero AND high >= entry price + take-profit distance
Exit: short, stop-loss distance is nonzero AND high >= entry price + stop-loss distance OR take-profit distance is nonzero AND low <= entry price - take-profit distance