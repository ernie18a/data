Calculation: Money Flow Index = RSI of the sum over a lookback of volume × hlc3 on bars where hlc3 rose, and the sum of volume × hlc3 on bars where hlc3 fell
Calculation: ROC momentum = EMA of close rate of change over a shorter lookback than the rate-of-change lookback
Calculation: SuperTrend lines = form upper and lower trails from hl2 ± a multiple of ATR; carry the upper trail forward as the maximum of its current value and prior upper trail when prior close exceeds prior upper trail, otherwise reset it; carry the lower trail forward as the minimum of its current value and prior lower trail when prior close is below prior lower trail, otherwise reset it; set trend up when close exceeds the prior lower trail, down when close is below the prior upper trail, otherwise retain prior trend (default up); select the trail matching trend as line 1 and the opposite trail as line 2
Calculation: Short SuperTrend line = short-lookback SMA of line 1
Calculation: Long SuperTrend line = longer-lookback SMA of line 2
Long: Long SuperTrend line > Short SuperTrend line AND Money Flow Index > its prior-bar value AND (ROC momentum > half the threshold OR ROC momentum < negative half the threshold)
Short: Long SuperTrend line < Short SuperTrend line AND Money Flow Index < its prior-bar value AND (ROC momentum > half the threshold OR ROC momentum < negative half the threshold)
Exit: long, low <= entry price × (1 − stop percentage)
Exit: short, high >= entry price × (1 + stop percentage)