Calculation: session-to-date lookback = current chart-bar index − index of the most recent chart bar in the start-time window + 1
Long: chart-bar time is within the entry-time window AND highest(high, session-to-date lookback) = high AND RSI(close, RSI lookback) > RSI threshold AND close > open
Short: chart-bar time is within the entry-time window AND lowest(low, session-to-date lookback) = low AND RSI(close, RSI lookback) < RSI threshold AND close < open
Exit: long, close < VWMA(close, VWMA lookback) OR chart-bar time is within the exit-time window
Exit: short, close > VWMA(close, VWMA lookback) OR chart-bar time is within the exit-time window