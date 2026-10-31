Calculation: Hull moving average H = linear weighted moving average over floor(sqrt(n)) bars of (2 × linear weighted moving average of the selected OHLC-derived price over floor(n/2) bars − linear weighted moving average of that price over n bars). Use the chart timeframe for indicator markings; for expert decisions, use the selected indicator timeframe, which may be higher or lower than the chart timeframe, and the selected signal bar, either the last completed bar or the bar still forming. Prior values refer to preceding bars of that same timeframe.
Calculation: D = H − previous H; S = population standard deviation of D over the selected lookback, including the signal bar. Round D and each of the two independently parameterized multiples of S to the selected price precision plus two decimal places; call the rounded values D, T1 and T2.
Long: H > previous H
Short: H < previous H
Long: (D > T1 AND D <= T2) OR D > T2
Short: (D < -T1 AND D >= -T2) OR D < -T2
Long: H > previous H AND previous H < H two bars ago
Short: H < previous H AND previous H > H two bars ago
Exit: long, (D < -T1 AND D >= -T2) OR D < -T2 OR H < previous H
Exit: short, (D > T1 AND D <= T2) OR D > T2 OR H > previous H
Exit: long, low <= entry price − stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price − take-profit distance