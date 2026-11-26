Long: MACD line(close, shorter lookback, longer lookback) > MACD line(close, shorter lookback, longer lookback)[1]
Short: MACD line(close, shorter lookback, longer lookback) <= MACD line(close, shorter lookback, longer lookback)[1]
Long: EMA(close, EMA A lookback) > EMA(close, EMA A lookback)[2]
Short: EMA(close, EMA A lookback) < EMA(close, EMA A lookback)[2]
Long: EMA(close, EMA B lookback) > EMA(close, EMA B lookback)[2]
Short: EMA(close, EMA B lookback) < EMA(close, EMA B lookback)[2]
Long: on chart bars, the close of the still-forming T1 bar crosses above its open
Short: on chart bars, the close of the still-forming T1 bar crosses below its open
Long: Supertrend direction changes from bearish to bullish
Short: Supertrend direction changes from bullish to bearish
Calculation: Triple EMA combination = EMA(EMA(EMA(close, triple EMA lookback), triple EMA lookback), triple EMA lookback) + EMA(close, triple EMA lookback) - EMA(EMA(close, triple EMA lookback), triple EMA lookback)
Calculation: Double EMA combination = 2 * EMA(close, longer EMA lookback) - EMA(EMA(close, longer EMA lookback), shorter EMA lookback)
Calculation: Signal level = if Triple EMA combination > Double EMA combination then max(EMA(highest(avg(low, close), fast lookback), fast lookback), EMA(lowest(avg(high, close), slow lookback), slow lookback)) else min(EMA(highest(avg(low, close), fast lookback), fast lookback), EMA(lowest(avg(high, close), slow lookback), slow lookback))
Long: Triple EMA combination > Double EMA combination AND Signal level > low AND Signal level - Signal level[1] > Signal level[1] - Signal level[2]
Short: Triple EMA combination < Double EMA combination AND Signal level < high AND Signal level[1] - Signal level > Signal level[2] - Signal level[1]