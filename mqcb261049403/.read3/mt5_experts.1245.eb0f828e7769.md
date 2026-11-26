Long: Anchored Momentum(T1, last completed bar) > upper threshold AND Anchored Momentum(T1, preceding completed bar) <= upper threshold
Short: Anchored Momentum(T1, last completed bar) < lower threshold AND Anchored Momentum(T1, preceding completed bar) <= lower threshold
Exit: short, Anchored Momentum(T1, last completed bar) > upper threshold
Exit: long, Anchored Momentum(T1, last completed bar) < lower threshold
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance