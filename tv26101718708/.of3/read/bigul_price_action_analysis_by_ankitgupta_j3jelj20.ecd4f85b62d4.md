Long: session open > upper CPR(high, low, close, T4, last completed bar)
Short: session open < lower CPR(high, low, close, T4, last completed bar)
Long: close(T1, still-forming bar) > upper CPR(high, low, close, T1, last completed bar) OR close(T2, still-forming bar) > upper CPR(high, low, close, T2, last completed bar) OR close(T3, still-forming bar) > upper CPR(high, low, close, T3, last completed bar), sampled on chart bars
Short: close(T1, still-forming bar) < lower CPR(high, low, close, T1, last completed bar) OR close(T2, still-forming bar) < lower CPR(high, low, close, T2, last completed bar) OR close(T3, still-forming bar) < lower CPR(high, low, close, T3, last completed bar), sampled on chart bars
Long: close crosses above high(T5, last completed bar), sampled on chart bars
Short: close crosses below low(T5, last completed bar), sampled on chart bars
Long: close >= VWAP(hlc3, volume, reset at session open)
Short: close < VWAP(hlc3, volume, reset at session open)
Long: close crosses above Initial Balance High
Short: close crosses below Initial Balance Low
Calculation: ZigZag pivot price = track the highest high or lowest low over the pivot lookback; switch direction only when one extreme occurs without the other; when both occur, choose the high in an up direction and the low otherwise; retain the most extreme same-direction pivot since the last direction change
Calculation: Consolidation count = increment the preceding count when the ZigZag pivot price is unchanged; when it changes, reset to zero if the preceding count is not greater than the minimum consolidation length, otherwise increment the preceding count
Calculation: Consolidation zone bounds = when the count first exceeds the minimum consolidation length, initialize the upper and lower bounds to the highest high and lowest low over that length; while the count exceeds that length, expand the bounds to include each bar's high and low
Long: ZigZag pivot price changes, exceeds the prior bar's consolidation-zone upper bound, and the prior bar's consolidation count exceeds the minimum consolidation length
Short: ZigZag pivot price changes, falls below the prior bar's consolidation-zone lower bound, and the prior bar's consolidation count exceeds the minimum consolidation length
Long: pair-bias branch selected AND Nifty futures close > upper CPR(high, low, close, T1, last completed bar) AND Bank Nifty futures close > upper CPR(high, low, close, T1, last completed bar)
Short: pair-bias branch selected AND Nifty futures close < lower CPR(high, low, close, T1, last completed bar) AND Bank Nifty futures close < lower CPR(high, low, close, T1, last completed bar)