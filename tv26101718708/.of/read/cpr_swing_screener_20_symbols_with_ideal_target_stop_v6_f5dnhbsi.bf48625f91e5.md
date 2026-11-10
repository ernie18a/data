Calculation: Previous-period high, low, and close = high, low, and final close accumulated from chart bars in the preceding completed calendar day.
Calculation: Pivot = (previous-period high + previous-period low + previous-period close) / 3.
Calculation: CPR midpoint = (previous-period high + previous-period low) / 2.
Calculation: CPR upper boundary = maximum of CPR midpoint and (2 × pivot − CPR midpoint).
Calculation: CPR lower boundary = minimum of CPR midpoint and (2 × pivot − CPR midpoint).
Calculation: CPR width percentage = 100 × (CPR upper boundary − CPR lower boundary) / current close.
Calculation: Resistance = 2 × pivot − previous-period low.
Calculation: Support = 2 × pivot − previous-period high.
Long: CPR width percentage <= narrow-width threshold AND close > CPR upper boundary AND close > resistance AND close > open AND (EMA filter disabled OR close > EMA of close) AND (volume filter disabled OR volume > SMA of volume × volume multiplier).
Long: CPR width percentage >= wide-width threshold AND low <= CPR lower boundary AND close > CPR lower boundary AND close > open AND (EMA filter disabled OR close > EMA of close).
Long: CPR width percentage <= narrow-width threshold AND close > pivot AND close <= resistance AND (EMA filter disabled OR close > EMA of close) AND NOT (CPR width percentage >= wide-width threshold AND high >= CPR upper boundary AND close < CPR upper boundary AND close < open AND (EMA filter disabled OR close < EMA of close)).
Short: CPR width percentage <= narrow-width threshold AND close < CPR lower boundary AND close < support AND close < open AND (EMA filter disabled OR close < EMA of close) AND (volume filter disabled OR volume > SMA of volume × volume multiplier).
Short: CPR width percentage >= wide-width threshold AND high >= CPR upper boundary AND close < CPR upper boundary AND close < open AND (EMA filter disabled OR close < EMA of close).
Short: CPR width percentage <= narrow-width threshold AND close < pivot AND close >= support AND (EMA filter disabled OR close < EMA of close) AND NOT (CPR width percentage >= wide-width threshold AND low <= CPR lower boundary AND close > CPR lower boundary AND close > open AND (EMA filter disabled OR close > EMA of close)).