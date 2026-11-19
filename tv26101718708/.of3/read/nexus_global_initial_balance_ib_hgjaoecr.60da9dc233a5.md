Calculation: IB high/low = highest high/lowest low during each configured initial-balance session window
Calculation: HTF fib level(ratio) = highest(high, lookback, T1 bars) - (highest(high, lookback, T1 bars) - lowest(low, lookback, T1 bars)) * ratio; calculate on T1 bars and use the still-forming T1 bar's value on chart bars
Calculation: IB retracement level(ratio) = IB high - (IB high - IB low) * ratio
Calculation: Upper IB extension(ratio) = IB high + (IB high - IB low) * ratio
Long: a prior chart bar had high > IB high while close > HTF fib level(bias-level ratio parameter) AND the current bar's low <= an HTF fib level <= its high, where the touched level is within the IB retracement zone between its separate shallow and deep ratio parameters and is one of three HTF pivot levels whose separate ratios are ordered shallower than, equal to, and deeper than the bias-level ratio
Short: low < IB low AND close < HTF fib level(bias-level ratio parameter)
Exit: long, low <= IB low - stop-offset parameter
Exit: long, after an IB-high breakout and before reaching the first upper IB extension, a later bar closed back inside the IB range and current low <= IB low
Exit: long, after price has reached the first upper IB extension, low <= entry price
Exit: long, high >= Upper IB extension(second extension-ratio parameter)
Exit: long, high >= Upper IB extension(third extension-ratio parameter)