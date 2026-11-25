Long: (RSI(close, RSI lookback, chart timeframe)[2] < oversold threshold AND RSI(close, RSI lookback, chart timeframe)[1] > oversold threshold AND long-position count = 0) OR (long-position count > 0 AND long-position count < position limit AND close > most recently opened long entry price + add-on distance)
Short: (RSI(close, RSI lookback, chart timeframe)[2] > overbought threshold AND RSI(close, RSI lookback, chart timeframe)[1] < overbought threshold AND short-position count = 0) OR (short-position count > 0 AND short-position count < position limit AND close < most recently opened short entry price - add-on distance)
Long: high >= High(T1, last completed bar) + box breakout offset
Short: low <= Low(T1, last completed bar) - box breakout offset
Long: high >= Highest(high, (weekly start-hour parameter + broker GMT-offset parameter) × bar-count multiplier, T2, including current forming bar) + weekly entry offset
Short: low <= Lowest(low, (weekly start-hour parameter + broker GMT-offset parameter) × bar-count multiplier, T2, including current forming bar) - weekly entry offset
Long: long-position count = 0 AND current hour = gap-entry hour parameter AND Open(T3, current forming bar) < Low(T3, last completed bar)
Short: long-position count = 0 AND short-position count = 0 AND current hour = gap-entry hour parameter AND Open(T3, current forming bar) > High(T3, last completed bar)
Exit: long, current hour = one of the box-clear hour parameters + broker GMT-offset parameter OR weekday = Friday AND current hour > Friday-close-hour parameter + broker GMT-offset parameter
Exit: short, current hour = one of the box-clear hour parameters + broker GMT-offset parameter OR weekday = Friday AND current hour > Friday-close-hour parameter + broker GMT-offset parameter