Calculation: Trend state = +1 if AbsolutelyNoLagLWMA(applied price, lookback, timeframe, bar) > AbsolutelyNoLagLWMA(applied price, lookback, timeframe, preceding bar), -1 if <, otherwise the previous trend state
Long: applied price > AbsolutelyNoLagLWMA(applied price, lookback)
Short: applied price < AbsolutelyNoLagLWMA(applied price, lookback)
Long: Trend state = +1
Short: Trend state = -1
Long: Trend state(T1 value mapped to chart bar selected by signal-bar offset; current T1 bar if still forming, otherwise last completed) = +1 AND Trend state(T1 value mapped to next older chart bar) != +1
Short: Trend state(T1 value mapped to chart bar selected by signal-bar offset; current T1 bar if still forming, otherwise last completed) = -1 AND Trend state(T1 value mapped to next older chart bar) != -1