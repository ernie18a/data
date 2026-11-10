Calculation: Confirmed swing high = a high greater than or equal to the highs of the preceding pivot-length bars and greater than the highs of the following pivot-length bars; it becomes available on the last following bar. Confirmed swing low = a low less than or equal to the lows of the preceding pivot-length bars and less than the lows of the following pivot-length bars; it becomes available on the last following bar. Use the same pivot length for highs and lows. Latest and previous swings refer to the two most recently confirmed swings of the specified kind, updated on the confirmation bar.
Calculation: Structure score = 1 for latest swing high > previous swing high, minus 1 for latest swing high < previous swing high, plus 1 for latest swing low > previous swing low, minus 1 for latest swing low < previous swing low; calculate only when both pairs exist.
Long: A swing high is newly confirmed AND latest swing high > previous swing high.
Short: A swing high is newly confirmed AND latest swing high <= previous swing high.
Long: A swing low is newly confirmed AND latest swing low > previous swing low.
Short: A swing low is newly confirmed AND latest swing low <= previous swing low.
Long: Structure score > 0.
Short: Structure score < 0.
Long: Close > latest confirmed swing high AND previous close <= the swing high that was latest on the previous bar.
Short: Close < latest confirmed swing low AND previous close >= the swing low that was latest on the previous bar.
Long: On either of two aggregation timeframes, one longer than the other, latest swing high > previous swing high AND latest swing low > previous swing low. Each aggregation timeframe can be higher or lower than the chart timeframe; for a higher timeframe use its last completed bar on historical chart bars and its forming bar on realtime chart bars; for a lower timeframe use the last available intrabar.