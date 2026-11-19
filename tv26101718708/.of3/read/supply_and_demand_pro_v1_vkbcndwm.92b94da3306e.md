Calculation: Early bullish momentum = (EMA(close, shorter EMA lookback) > EMA(close, middle EMA lookback) OR close > EMA(close, shorter EMA lookback)) AND RSI(close, RSI lookback) > RSI midline
Calculation: Early bearish momentum = (EMA(close, shorter EMA lookback) < EMA(close, middle EMA lookback) OR close < EMA(close, shorter EMA lookback)) AND RSI(close, RSI lookback) < RSI midline
Calculation: Upward structure break = close > Highest(high, structure lookback)[1] AND close[1] <= Highest(high, structure lookback)[1]
Calculation: Downward structure break = close < Lowest(low, structure lookback)[1] AND close[1] >= Lowest(low, structure lookback)[1]
Calculation: Average candle body on T1 bars = SMA(abs(close - open), body-average lookback)
Calculation: Demand-zone signal on T1 bars = close - open > average candle body * large-body factor AND abs(close[base-candle offset] - open[base-candle offset]) < average candle body * small-body factor
Calculation: Supply-zone signal on T1 bars = open - close > average candle body * large-body factor AND abs(close[base-candle offset] - open[base-candle offset]) < average candle body * small-body factor
Long: Early bullish momentum
Short: Early bearish momentum
Long: Upward structure break
Short: Downward structure break
Long: Demand-zone signal returned to chart bars using lookahead off (developing T1 bar in real time; completed T1 value historically)
Short: Supply-zone signal returned to chart bars using lookahead off (developing T1 bar in real time; completed T1 value historically)
Long: Early bullish momentum AND RSI(close, RSI lookback) > RSI midline + RSI breakout offset AND upward structure break AND (session filter disabled OR chart bar is within the selected session window in New York time) AND at least the signal cooldown chart bars have elapsed since the previous aggressive or continuation long signal, or none has occurred
Short: Early bearish momentum AND RSI(close, RSI lookback) < RSI midline - RSI breakout offset AND downward structure break AND (session filter disabled OR chart bar is within the selected session window in New York time) AND at least the signal cooldown chart bars have elapsed since the previous aggressive or continuation short signal, or none has occurred
Long: EMA(close, shorter EMA lookback) > EMA(close, middle EMA lookback) AND EMA(close, middle EMA lookback) > EMA(close, longer EMA lookback) AND RSI(close, RSI lookback) > RSI midline AND an upward structure break occurred within the signal-window chart bars AND (session filter disabled OR chart bar is within the selected session window in New York time) AND at least the signal cooldown chart bars have elapsed since the previous aggressive or continuation long signal, or none has occurred AND more than the aggressive-to-continuation wait chart bars have elapsed since the previous aggressive long signal, or none has occurred
Short: EMA(close, shorter EMA lookback) < EMA(close, middle EMA lookback) AND EMA(close, middle EMA lookback) < EMA(close, longer EMA lookback) AND RSI(close, RSI lookback) < RSI midline AND a downward structure break occurred within the signal-window chart bars AND (session filter disabled OR chart bar is within the selected session window in New York time) AND at least the signal cooldown chart bars have elapsed since the previous aggressive or continuation short signal, or none has occurred AND more than the aggressive-to-continuation wait chart bars have elapsed since the previous aggressive short signal, or none has occurred
Calculation: Long reference entry price = close at the latest aggressive long signal
Calculation: Short reference entry price = close at the latest aggressive short signal
Calculation: Long stop price = min(low[1], low) * (1 - stop buffer percentage / 100) at the latest aggressive long signal
Calculation: Short stop price = max(high[1], high) * (1 + stop buffer percentage / 100) at the latest aggressive short signal
Calculation: Long risk = long reference entry price - long stop price
Calculation: Short risk = short stop price - short reference entry price
Calculation: Long target 1 = long reference entry price + long risk * first target multiple
Calculation: Long target 2 = long reference entry price + long risk * second target multiple
Calculation: Long target 3 = long reference entry price + long risk * third target multiple
Calculation: Short target 1 = short reference entry price - short risk * first target multiple
Calculation: Short target 2 = short reference entry price - short risk * second target multiple
Calculation: Short target 3 = short reference entry price - short risk * third target multiple
Exit: Long, low <= long stop price OR (high >= long target 1 AND low[1] < long target 1) OR (high >= long target 2 AND low[1] < long target 2) OR (high >= long target 3 AND low[1] < long target 3)
Exit: Short, high >= short stop price OR (low <= short target 1 AND high[1] > short target 1) OR (low <= short target 2 AND high[1] > short target 2) OR (low <= short target 3 AND high[1] > short target 3)