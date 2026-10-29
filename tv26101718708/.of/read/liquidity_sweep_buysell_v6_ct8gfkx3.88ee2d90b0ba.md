Calculation: Latest confirmed swing high = the high of the most recent bar whose high is greater than the highs of the specified number of preceding and following chart-timeframe bars; it becomes available after those following bars complete.
Calculation: Latest confirmed swing low = the low of the most recent bar whose low is less than the lows of the specified number of preceding and following chart-timeframe bars; it becomes available after those following bars complete.
Calculation: EMA = exponential moving average of chart-timeframe close.
Calculation: Volume average = simple moving average of chart-timeframe volume.
Long: low <= latest confirmed swing low × (1 − sweep tolerance %) AND close > latest confirmed swing low AND (close > EMA when the EMA filter is enabled) AND (volume > volume average when the volume filter is enabled)
Short: high >= latest confirmed swing high × (1 + sweep tolerance %) AND close < latest confirmed swing high AND (close < EMA when the EMA filter is enabled) AND (volume > volume average when the volume filter is enabled)
Exit: long, high >= latest confirmed swing high × (1 + sweep tolerance %) AND close < latest confirmed swing high
Exit: short, low <= latest confirmed swing low × (1 − sweep tolerance %) AND close > latest confirmed swing low