Long: Stochastic(..., T1, last completed bar), sampled on chart bars, < oversold level AND (hour(datetime) >= session start hour OR hour(datetime) < session end hour)
Short: Stochastic(..., T1, last completed bar), sampled on chart bars, > overbought level AND (hour(datetime) >= session start hour OR hour(datetime) < session end hour)
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance