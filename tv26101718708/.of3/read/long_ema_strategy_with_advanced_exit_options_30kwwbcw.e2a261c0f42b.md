Calculation: Selected moving average(source, lookback) = EMA, SMA, WMA, or HMA(source, lookback), selected by the moving-average-type parameter
Calculation: Highest high since entry = maximum high from the entry bar through the current bar
Long: close > selected moving average(close, long-term lookback) AND (selected moving average(close, short-term lookback) crosses above selected moving average(close, medium-term lookback) OR selected moving average(close, short-term lookback) > selected moving average(close, medium-term lookback))
Exit: long, MACD(source, fast lookback, slow lookback, signal smoothing, T1) crosses below its signal line on chart bars, using the current T1 value (developing in realtime; last completed value on historical chart bars until T1 closes)
Exit: long, close < selected moving average(close, exit lookback)
Exit: long, low <= Highest high since entry * (1 - trailing-stop percentage)
Exit: long, selected moving average(close, short-term lookback) crosses below selected moving average(close, medium-term lookback)