Calculation: Confirmed swing high or low = a high or low that is respectively the highest or lowest over equal numbers of bars before and after it; recognize it when the later bars have completed.
Calculation: Labeled structure pivots = retain alternating confirmed swing highs and lows within the structure lookback; replace consecutive pivots of the same type only when the new pivot is more extreme. When appending a pivot after an opposite-type pivot, compare it with the previous appended pivot of the same type; replacements do not update that comparison value.
Long: low > high two bars ago AND low - high two bars ago >= ATR multiplied by a minimum gap factor.
Short: high < low two bars ago AND low two bars ago - high >= ATR multiplied by a minimum gap factor.
Long: low < latest confirmed swing low AND close > latest confirmed swing low AND min(open, close) - low >= ATR multiplied by a minimum wick factor.
Short: high > latest confirmed swing high AND close < latest confirmed swing high AND high - max(open, close) >= ATR multiplied by a minimum wick factor.
Long: close > latest confirmed swing high AND previous close <= that same swing high.
Short: close < latest confirmed swing low AND previous close >= that same swing low.
Long: newly appended structure pivot high > previous appended structure pivot high OR newly appended structure pivot low > previous appended structure pivot low.
Short: newly appended structure pivot high <= previous appended structure pivot high OR newly appended structure pivot low <= previous appended structure pivot low.