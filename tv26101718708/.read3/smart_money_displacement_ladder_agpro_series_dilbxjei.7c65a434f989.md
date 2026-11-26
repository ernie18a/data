Calculation: BullDisp = close > open AND ABS(close - open) >= body multiple * ATR(atr lookback) AND high - low >= range multiple * ATR(atr lookback) AND (close - low) / (high - low) * 100 >= close strength threshold
Calculation: BearDisp = close < open AND ABS(close - open) >= body multiple * ATR(atr lookback) AND high - low >= range multiple * ATR(atr lookback) AND (high - close) / (high - low) * 100 >= close strength threshold
Calculation: AnchorDir = +1 if BullDisp, -1 if BearDisp, on the latest bar where BullDisp or BearDisp holds (the anchor bar); 0 before any anchor bar
Calculation: ShelfLevel = MAX(open, low + shelf multiple * ATR(atr lookback)) when AnchorDir = +1, else MIN(open, high - shelf multiple * ATR(atr lookback)), with open, high, low and ATR taken on the anchor bar
Calculation: LadderLevel = MAX(high on the anchor bar, close on each bar after the anchor bar through the previous bar) when AnchorDir = +1, else MIN(low on the anchor bar, close on each bar after the anchor bar through the previous bar)
Calculation: Failed = true if some bar from the anchor bar through this bar, at most failure window bars after the anchor bar, has close < ShelfLevel when AnchorDir = +1 or close > ShelfLevel when AnchorDir = -1; else false
Long: BullDisp = true
Short: BearDisp = true
Long: AnchorDir = +1 AND Failed[1] = false AND close > LadderLevel
Short: AnchorDir = -1 AND Failed[1] = false AND close < LadderLevel
Exit: long, AnchorDir = +1 AND Failed = true AND Failed[1] = false
Exit: short, AnchorDir = -1 AND Failed = true AND Failed[1] = false
Long: AnchorDir = +1 AND Failed = false
Short: AnchorDir = -1 AND Failed = false
Exit: long, AnchorDir = +1 AND Failed = true
Exit: short, AnchorDir = -1 AND Failed = true