Calculation: Smoothed close = ((period - 1) × previous smoothed close + close) / period, initialized with the second available bar's close. Calculate on a configurable timeframe that may be higher or lower than the chart timeframe, using the last completed bar or, optionally, the bar still forming. Let S0 be its value at the selected bar, S1 at the preceding bar, and S2 at the bar before that.
Long: S0 > S1 AND S1 < S2
Short: S0 < S1 AND S1 > S2
Exit: long, S0 < S1 OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, S0 > S1 OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance