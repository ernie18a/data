Calculation: previous Asian-session high = maximum high during the previous Asian session, or 0 if unavailable
Calculation: previous Asian-session low = minimum low during the previous Asian session, or 0 if unavailable
Long: (low < previous Asian-session low OR low < low of the last completed T1 bar OR low < low of the last completed T2 bar OR low < low of the last completed T3 bar) AND close > open
Short: (high > previous Asian-session high OR high > high of the last completed T1 bar OR high > high of the last completed T2 bar OR high > high of the last completed T3 bar) AND close < open
Exit: long, low <= entry price - ATR(lookback) × stop multiplier OR high >= entry price + ATR(lookback) × target multiplier
Exit: short, high >= entry price + ATR(lookback) × stop multiplier OR low <= entry price - ATR(lookback) × target multiplier