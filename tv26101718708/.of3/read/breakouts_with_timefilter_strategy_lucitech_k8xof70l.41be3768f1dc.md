Calculation: Tracked pivot highs = the most recent N confirmed Pivot High(high, pivot lookback, pivot lookback) levels, removing each after a bar closes above it
Calculation: Tracked pivot lows = the most recent N confirmed Pivot Low(low, pivot lookback, pivot lookback) levels, removing each after a bar closes below it
Calculation: Initial stop at the signal bar = for a long, low minus ATR(ATR lookback, selected RMA/SMA/EMA/WMA smoothing) times ATR multiplier, low[bars back], or close minus fixed price distance, according to selected stop type; for a short, high plus ATR(ATR lookback, selected RMA/SMA/EMA/WMA smoothing) times ATR multiplier, high[bars back], or close plus fixed price distance, according to selected stop type
Calculation: Target at the signal bar = for a long, close + reward multiple × (close − initial stop); for a short, close − reward multiple × (initial stop − close)
Long: close > any tracked pivot high AND (MA filter disabled OR close > selected SMA/EMA/WMA/VWMA/HMA(ma source, MA lookback))
Long: close > any tracked pivot high AND (MA filter disabled OR close > selected SMA/EMA/WMA/VWMA/HMA(ma source, MA lookback)) AND (time filter disabled OR chart bar close time in the configured Europe/London window, inclusive) AND close > initial stop
Short: close < any tracked pivot low AND (MA filter disabled OR close < selected SMA/EMA/WMA/VWMA/HMA(ma source, MA lookback))
Short: close < any tracked pivot low AND (MA filter disabled OR close < selected SMA/EMA/WMA/VWMA/HMA(ma source, MA lookback)) AND (time filter disabled OR chart bar close time in the configured Europe/London window, inclusive) AND initial stop > close
Exit: long, low <= initial stop OR high >= target
Exit: short, high >= initial stop OR low <= target