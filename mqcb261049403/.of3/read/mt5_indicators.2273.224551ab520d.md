Calculation: long state = per evaluated timeframe, if close < lowest(low[1], lookback) then true, else if close > highest(high[1], lookback) then false, else previous long state; initially false
Calculation: short state = per evaluated timeframe, if close > highest(high[1], lookback) then true, else if close < lowest(low[1], lookback) then false, else previous short state; initially false
Long: close < lowest(low[1], lookback) AND long state[1] = false
Short: close > highest(high[1], lookback) AND short state[1] = false
Long: On the first chart bar of each T1 period, close(T1, still forming) < lowest(low, lookback, T1, last completed bar) AND long state(T1)[1] = false
Short: On the first chart bar of each T1 period, close(T1, still forming) > highest(high, lookback, T1, last completed bar) AND short state(T1)[1] = false