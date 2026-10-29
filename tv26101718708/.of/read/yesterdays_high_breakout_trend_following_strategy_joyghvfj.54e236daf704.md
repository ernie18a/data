Calculation: Previous daily high = highest high of the last completed bar aggregated to a higher daily timeframe
Calculation: ROC = (chart close − previous completed daily close) / previous completed daily close × 100
Long: close < previous daily high AND high >= previous daily high × (1 + gap%) AND (ROC filter disabled OR ROC > ROC threshold)
Exit: long, low <= entry price × (1 − stop-loss%) OR high >= entry price × (1 + take-profit%) OR (trailing stop enabled AND high reaches entry price + trailing activation distance AND low <= highest high since activation − trailing offset) OR (EMA close enabled AND close crosses below EMA)
