Calculation: Trend = for each bar, let H be the maximum of the current low and the highs over a lookback including the current bar; let L be the minimum of the current close and the lows over that same lookback; let f = (33 − risk parameter) / 100. Start at 0; set trend to −1 if close < L + (H − L) × f, then set it to +1 if close > H − (H − L) × f; otherwise retain the previous trend. Calculate independent trends for the long and short systems with independently configurable lookbacks and risk parameters. Each system can use chart bars or bars of a higher or lower timeframe, evaluated on a configurable signal bar: the last completed bar or the bar still forming, with the previous bar immediately preceding it.
Long: chart-timeframe trend > 0
Short: chart-timeframe trend < 0
Long: long-system signal-bar trend > 0 AND previous-bar trend ≤ 0
Short: short-system signal-bar trend < 0 AND (previous-bar trend ≤ 0 OR previous-bar trend > 0 AND previous-bar open > previous-bar close)
Exit: long, long-system signal-bar trend < 0
Exit: short, short-system signal-bar trend > 0
Exit: long, low ≤ entry price − stop-loss distance OR high ≥ entry price + take-profit distance
Exit: short, high ≥ entry price + stop-loss distance OR low ≤ entry price − take-profit distance