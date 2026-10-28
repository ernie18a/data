Calculation: Latest confirmed swing high = the most recent high greater than the highs of the preceding and following N bars
Calculation: Latest confirmed swing low = the most recent low lower than the lows of the preceding and following N bars
Calculation: EMA = exponential moving average of close over a configurable lookback
Calculation: Average volume = simple moving average of volume over a configurable lookback
Long: low <= latest confirmed swing low × (1 − sweep tolerance %) AND close > latest confirmed swing low AND (EMA filter disabled OR close > EMA) AND (volume filter disabled OR volume > average volume)
Short: high >= latest confirmed swing high × (1 + sweep tolerance %) AND close < latest confirmed swing high AND (EMA filter disabled OR close < EMA) AND (volume filter disabled OR volume > average volume)
Exit: long, high >= latest confirmed swing high × (1 + sweep tolerance %) AND close < latest confirmed swing high
Exit: short, low <= latest confirmed swing low × (1 − sweep tolerance %) AND close > latest confirmed swing low