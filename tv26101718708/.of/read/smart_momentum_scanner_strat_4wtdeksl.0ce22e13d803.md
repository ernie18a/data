Calculation: Support setup = the latest confirmed pivot low while waiting for support; retain it through the reversal, higher-low, and continuation stages.
Calculation: Confirmed pivot low = a bar low lower than the configured number of preceding and following bar lows; it is available after those following bars complete.
Calculation: Reversal high = the high of a bullish candle that tests support (low <= support × (1 + tolerance)) and closes above the previous bar's high.
Calculation: Higher low = a confirmed pivot low above support, found after the reversal.
Calculation: Continuation = after the higher low, close above the reversal high.
Calculation: Early recovery = close > EMA(short-term) AND EMA(shorter-term) > EMA(longer-term) AND EMA(longer-term) > its value five chart bars earlier.
Calculation: Established trend = close > EMA(long-term) AND EMA(shorter-term) > EMA(longer-term) AND EMA(longer-term) > EMA(intermediate-term) AND EMA(long-term) > its value five chart bars earlier.
Calculation: Average volume = simple moving average of volume over a lookback period.
Long: Continuation AND volume >= average volume × confirmation multiplier AND (early recovery OR established trend) AND close > VWAP
Calculation: Long stop = the lower of (the higher of support recorded for the trade minus an ATR buffer and entry price minus the maximum ATR risk distance) and entry price minus one minimum price tick; ATR is captured at entry.
Exit: Long, low <= long stop OR close < EMA(longer-term)