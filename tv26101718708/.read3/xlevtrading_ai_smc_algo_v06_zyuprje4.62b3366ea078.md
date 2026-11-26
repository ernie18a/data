Calculation: body ratio = abs(close - open) / (high - low)
Calculation: Leg(L) = bearish if high[L] > max(high[0..L-1]); otherwise bullish if low[L] < min(low[0..L-1]); otherwise Leg(L)[1]
Calculation: SwingHigh(L) = high[L] on the latest bar where Leg(L) changed to bearish
Calculation: SwingLow(L) = low[L] on the latest bar where Leg(L) changed to bullish
Calculation: UpBreak(L) = +1 on the first qualifying bar where close crosses above SwingHigh(L) since SwingHigh(L) was set, otherwise 0; for the shorter lookback a crossing qualifies only if SwingHigh(shorter lookback) != SwingHigh(longer lookback)
Calculation: DownBreak(L) = +1 on the first qualifying bar where close crosses below SwingLow(L) since SwingLow(L) was set, otherwise 0; for the shorter lookback a crossing qualifies only if SwingLow(shorter lookback) != SwingLow(longer lookback)
Calculation: Trend(L) = bullish if UpBreak(L) = +1; bearish if DownBreak(L) = +1; otherwise Trend(L)[1]
Calculation: PendingChoch = the latest internal CHoCH, where an internal CHoCH is UpBreak(shorter lookback) = +1 with Trend(shorter lookback)[1] = bearish, or DownBreak(shorter lookback) = +1 with Trend(shorter lookback)[1] = bullish; it keeps its direction, bar, level (SwingHigh or SwingLow of the shorter lookback on that bar) and bar close, and is cleared when Entry != 0 or when its bar is more than follow-through bars old
Calculation: Entry = +1 if PendingChoch is bullish and [(PendingChoch is from this bar and (high - max(open, close)) / (high - low) <= wick threshold or body ratio >= body threshold) and high - low >= tiny range multiple * ATR(atr length)] or [PendingChoch is from 1 to follow-through bars ago and close > PendingChoch level + follow-through buffer * ATR(atr length) and close >= close of PendingChoch bar]; Entry = -1 if PendingChoch is bearish and [(PendingChoch is from this bar and (min(open, close) - low) / (high - low) <= wick threshold or body ratio >= body threshold) and high - low >= tiny range multiple * ATR(atr length)] or [PendingChoch is from 1 to follow-through bars ago and close < PendingChoch level - follow-through buffer * ATR(atr length) and close <= close of PendingChoch bar]; otherwise Entry = 0
Calculation: NoEntry(N) = +1 if Entry is 0 on this bar and on each of the previous N bars, otherwise 0
Long: Entry = +1
Short: Entry = -1
Long: NoEntry(entry freshness bars) = +1 AND Trend(longer lookback) = bullish AND Trend(shorter lookback) != bullish
Long: NoEntry(entry freshness bars) = +1 AND Trend(longer lookback) = bearish AND Trend(shorter lookback) = bearish
Short: NoEntry(entry freshness bars) = +1 AND Trend(longer lookback) = bullish AND Trend(shorter lookback) = bullish
Short: NoEntry(entry freshness bars) = +1 AND Trend(longer lookback) = bearish AND Trend(shorter lookback) != bearish
Long: UpBreak(shorter lookback) = +1 OR UpBreak(longer lookback) = +1
Short: DownBreak(shorter lookback) = +1 OR DownBreak(longer lookback) = +1