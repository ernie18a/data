Calculation: Order block top = high[order-block offset] at the latest chart bar where Pivot High(high, pivot lookback) confirms
Calculation: Order block bottom = low[order-block offset] at the latest chart bar where Pivot Low(low, pivot lookback) confirms
Calculation: Fibonacci level = order block bottom + (order block top - order block bottom) * Fibonacci ratio, updated when either pivot confirms
Long: low > high[2] AND close[1] > high[2]
Short: high < low[2] AND close[1] < low[2]
Short: close < the lower boundary (high[2] on its formation bar) of any previously formed bullish FVG
Long: position is flat AND close > SMA(close, macro lookback) AND EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback) AND (close <= Fibonacci level OR low <= order block bottom) AND ((low > high[2] AND close[1] > high[2]) OR close crosses above EMA(close, shorter EMA lookback))
Short: position is flat AND close < SMA(close, macro lookback) AND EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback) AND (close >= Fibonacci level OR high >= order block top) AND ((high < low[2] AND close[1] < low[2]) OR close crosses below EMA(close, shorter EMA lookback))
Exit: Long, low <= T1 low sampled at entry OR high >= T1 high sampled at entry; T1 values are supplied on chart bars by lookahead-off security, using the last completed T1 bar historically and the still-forming T1 bar in real time
Exit: Short, high >= T1 high sampled at entry OR low <= T1 low sampled at entry; T1 values are supplied on chart bars by lookahead-off security, using the last completed T1 bar historically and the still-forming T1 bar in real time