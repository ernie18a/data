Calculation: Average candle body = SMA(abs(close - open), body-average lookback) on T1 bars
Calculation: Upward BOS = close > Highest(high, BOS lookback)[1] AND close[1] <= Highest(high, BOS lookback)[1] on chart bars
Calculation: Downward BOS = close < Lowest(low, BOS lookback)[1] AND close[1] >= Lowest(low, BOS lookback)[1] on chart bars
Calculation: Early bullish momentum = (EMA(close, shortest lookback) > EMA(close, intermediate lookback) OR close > EMA(close, shortest lookback)) AND RSI(close, RSI lookback) > RSI midpoint
Calculation: Early bearish momentum = (EMA(close, shortest lookback) < EMA(close, intermediate lookback) OR close < EMA(close, shortest lookback)) AND RSI(close, RSI lookback) < RSI midpoint
Calculation: Strong bullish trend = EMA(close, shortest lookback) > EMA(close, intermediate lookback) AND EMA(close, intermediate lookback) > EMA(close, longest lookback) AND RSI(close, RSI lookback) > RSI midpoint
Calculation: Strong bearish trend = EMA(close, shortest lookback) < EMA(close, intermediate lookback) AND EMA(close, intermediate lookback) < EMA(close, longest lookback) AND RSI(close, RSI lookback) < RSI midpoint
Calculation: Long stop price = min(low, low[1]) on the most recent X-long signal bar * (1 - stop buffer / 100)
Calculation: Short stop price = max(high, high[1]) on the most recent X-short signal bar * (1 + stop buffer / 100)
Calculation: Long risk distance = X entry price - Long stop price
Calculation: Short risk distance = Short stop price - X entry price
Calculation: Long TP1 = X entry price + Long risk distance * TP1 multiple
Calculation: Long TP2 = X entry price + Long risk distance * TP2 multiple
Calculation: Long TP3 = X entry price + Long risk distance * TP3 multiple
Calculation: Short TP1 = X entry price - Short risk distance * TP1 multiple
Calculation: Short TP2 = X entry price - Short risk distance * TP2 multiple
Calculation: Short TP3 = X entry price - Short risk distance * TP3 multiple
Long: Early bullish momentum
Short: Early bearish momentum
Long: Upward BOS
Short: Downward BOS
Long: On chart bars taking values from the last completed T1 bar, close - open > Average candle body * large-body multiplier AND abs(close[3] - open[3]) < Average candle body * small-body multiplier
Short: On chart bars taking values from the last completed T1 bar, open - close > Average candle body * large-body multiplier AND abs(close[3] - open[3]) < Average candle body * small-body multiplier
Long: Early bullish momentum AND RSI(close, RSI lookback) > RSI midpoint + RSI margin AND Upward BOS AND (session filter disabled OR datetime is within the selected session window in America/New_York) AND (no prior long X/M signal OR bars since the latest long X/M signal >= same-side cooldown)
Short: Early bearish momentum AND RSI(close, RSI lookback) < RSI midpoint - RSI margin AND Downward BOS AND (session filter disabled OR datetime is within the selected session window in America/New_York) AND (no prior short X/M signal OR bars since the latest short X/M signal >= same-side cooldown)
Long: Strong bullish trend AND bars since Upward BOS <= signal window AND (session filter disabled OR datetime is within the selected session window in America/New_York) AND (no prior long X/M signal OR bars since the latest long X/M signal >= same-side cooldown) AND NOT (Upward BOS AND RSI(close, RSI lookback) > RSI midpoint + RSI margin) AND (no prior long X signal OR bars since the latest long X signal > continuation delay)
Short: Strong bearish trend AND bars since Downward BOS <= signal window AND (session filter disabled OR datetime is within the selected session window in America/New_York) AND (no prior short X/M signal OR bars since the latest short X/M signal >= same-side cooldown) AND NOT (Downward BOS AND RSI(close, RSI lookback) < RSI midpoint - RSI margin) AND (no prior short X signal OR bars since the latest short X signal > continuation delay)
Exit: Long, most recent X signal was long AND (low <= Long stop price OR (high >= Long TP1 AND low[1] < Long TP1) OR (high >= Long TP2 AND low[1] < Long TP2) OR (high >= Long TP3 AND low[1] < Long TP3))
Exit: Short, most recent X signal was short AND (high >= Short stop price OR (low <= Short TP1 AND high[1] > Short TP1) OR (low <= Short TP2 AND high[1] > Short TP2) OR (low <= Short TP3 AND high[1] > Short TP3))