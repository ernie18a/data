Calculation: Fast Williams %R = 100 × (close − highest high over the shorter lookback) ÷ (highest high − lowest low over that lookback), optionally smoothed.
Calculation: Slow Williams %R = 100 × (close − highest high over the longer lookback) ÷ (highest high − lowest low over that lookback), optionally smoothed.
Calculation: Average Williams %R = the average of the unsmoothed fast and slow Williams %R values, optionally smoothed.
Calculation: Overbought zone = fast and slow Williams %R are each at or above −threshold; in average mode, average Williams %R is at or above −threshold.
Calculation: Oversold zone = fast and slow Williams %R are each at or below −100 + threshold; in average mode, average Williams %R is at or below −100 + threshold.
Calculation: Higher-timeframe slow Williams %R = slow Williams %R on the last completed bar of a higher timeframe.
Long: Oversold zone is true on the previous bar and false on the current bar, AND each enabled filter passes: the prior oversold-zone duration meets the minimum; an in-zone bullish divergence exists (price makes a lower low while fast Williams %R, or average Williams %R in average mode, is higher by at least the divergence margin than at the prior in-zone low); higher-timeframe filter permits longs (higher-timeframe Williams %R > −100 + threshold in extreme-blocking mode, or > −50 in bias mode); price confirmation is disabled or close > the highest high of the preceding reference bars within the confirmation window without re-entering the oversold zone; and, when close-only signals are enabled, the bar is closed.
Short: Overbought zone is true on the previous bar and false on the current bar, AND each enabled filter passes: the prior overbought-zone duration meets the minimum; an in-zone bearish divergence exists (price makes a higher high while fast Williams %R, or average Williams %R in average mode, is lower by at least the divergence margin than at the prior in-zone high); higher-timeframe filter permits shorts (higher-timeframe Williams %R < −threshold in extreme-blocking mode, or < −50 in bias mode); price confirmation is disabled or close < the lowest low of the preceding reference bars within the confirmation window without re-entering the overbought zone; and, when close-only signals are enabled, the bar is closed.
Long: Oversold zone starts (oversold now and not on the previous bar).
Short: Overbought zone starts (overbought now and not on the previous bar).
Long: Fast and slow Williams %R are both above −50, and either crosses above −50 on the current bar; in average mode, average Williams %R crosses above −50.
Short: Fast and slow Williams %R are both below −50, and either crosses below −50 on the current bar; in average mode, average Williams %R crosses below −50.
Long: In standard mode, slow Williams %R crosses below fast Williams %R.
Short: In standard mode, slow Williams %R crosses above fast Williams %R.
Exit: Long, an opposite short-entry condition is met.
Exit: Short, an opposite long-entry condition is met.
Exit: Long, slow Williams %R crosses below −50; in average mode, average Williams %R crosses below −50.
Exit: Short, slow Williams %R crosses above −50; in average mode, average Williams %R crosses above −50.