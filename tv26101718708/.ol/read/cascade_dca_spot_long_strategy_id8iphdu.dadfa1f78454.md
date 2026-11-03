Calculation: Swing high = highest high over a lookback period.
Calculation: Bollinger Band Width = (upper Bollinger Band − lower Bollinger Band) / middle Bollinger Band × 100.
Calculation: Lateral zone = Bollinger Band Width below its threshold AND ADX below its threshold in strict mode; otherwise either condition is sufficient.
Calculation: DCA trigger for level n = initial entry price × (1 − drop(n)/100), where drop(n) is either first DCA drop + (n−1) × fixed increment, or first DCA drop × multiplier^(n−1).
Calculation: Cycle low = lowest low since the last fill; bars since cycle low counts consecutive bars without a new cycle low.
Calculation: VWM = EMA of ROC(close, lookback) × (volume / SMA(volume, a separate lookback)); the ROC lookback, volume-average lookback, and EMA smoothing lookback are independently configurable.
Calculation: VWM decay = consecutive bars on which VWM is lower than on the preceding bar.
Calculation: Supertrend direction = bullish when its direction is below zero and bearish when above zero.
Calculation: Trend EMA = EMA(close, its own lookback).
Calculation: Rescue breakeven is armed after the number of filled DCA levels reaches a threshold and close reaches the average position entry price plus a configurable percentage; once armed, it remains armed until the position closes.
Long: No open position AND close > 0 AND ((close ≤ swing high × (1 − initial drop percentage) AND lateral zone) OR (re-entry is enabled after a position closes AND Supertrend is bullish AND ADX ≥ trend-strength threshold AND +DI > −DI AND close > trend EMA AND close > close from a configurable number of bars earlier AND NOT lateral zone)).
Long: Long position open AND a DCA level remains AND lateral zone AND (rebound mode disabled AND close ≤ that level's DCA trigger OR rebound mode enabled AND cycle low ≤ that level's DCA trigger AND cycle low ≤ last fill × (1 − minimum gap percentage) AND cycle low has been unchanged for at least the confirmation-bar count AND close ≥ cycle low × (1 + rebound percentage) AND (green-candle requirement disabled OR close > open)).
Exit: Long, close > average position entry price × (1 + minimum profit percentage) AND ((VWM decay count ≥ required consecutive bars AND VWM from that many bars earlier > threshold) OR (Supertrend safety exit enabled AND Supertrend direction crosses from below zero to above zero)).
Exit: Long, rescue breakeven is armed AND open profit ≤ 0.