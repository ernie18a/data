Calculation: Positive VIX component = 100 * (highest close over a lookback - low) / highest close over the same lookback
Calculation: Negative VIX component = 100 * (lowest close over the same lookback - high) / lowest close over the same lookback
Calculation: Combined VIX = positive VIX component + negative VIX component
Calculation: Upper threshold = moving average of positive VIX component * upper factor
Calculation: Lower threshold = moving average of negative VIX component using the same type and length as the upper threshold * lower factor
Calculation: Upper extreme = (combined VIX > upper Bollinger Band of combined VIX OR combined VIX >= highest combined VIX over a range lookback * upper range factor) AND combined VIX > 0
Calculation: Lower extreme = (combined VIX < lower Bollinger Band of combined VIX OR combined VIX <= lowest combined VIX over the same range lookback * lower range factor) AND combined VIX < 0
Calculation: Buy condition = (combined VIX crosses above upper threshold AND MACD line < 0) OR (combined VIX > upper threshold AND upper extreme); calculate MACD on a selectable lower or higher timeframe, using the last available lower-timeframe bar or the last completed higher-timeframe bar on historical chart bars, and the still-forming requested-timeframe bar on realtime chart bars
Calculation: Sell condition = (combined VIX crosses below lower threshold AND MACD line > 0) OR (combined VIX < lower threshold AND lower extreme)
Long: Buy condition AND (buy-level filter disabled OR close < buy level) AND (entry moving-average filter disabled OR close < entry moving average * entry factor)
Short: Sell condition
Short: Sell condition AND ((sell-level filter disabled AND shorting disabled) OR close >= sell level)
Exit: long, sell condition
Exit: long, stop-loss enabled AND low <= close on the entry-signal bar * stop-loss factor
Exit: long, fixed-duration exit enabled AND bars since entry >= holding-period threshold
Exit: short, fixed-duration exit enabled AND bars since entry >= holding-period threshold