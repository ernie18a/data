Calculation: UpTrend = close > EMA(close, trend EMA length) AND EMA(close, trend EMA length) > EMA(close, trend EMA length)[slope lookback] AND (NOT HTF filter on OR close > EMA(close, trend EMA length, T1, last completed bar)[1])
Calculation: DownTrend = close < EMA(close, trend EMA length) AND EMA(close, trend EMA length) < EMA(close, trend EMA length)[slope lookback] AND (NOT HTF filter on OR close < EMA(close, trend EMA length, T1, last completed bar)[1])
Long: close crosses above Highest(high, breakout lookback)[1] AND (NOT trend filter on OR UpTrend OR (NOT with-trend only AND NOT DownTrend))
Short: close crosses below Lowest(low, breakout lookback)[1] AND (NOT trend filter on OR DownTrend OR (NOT with-trend only AND NOT UpTrend))
Long: UpTrend AND (Highest(high, breakout lookback)[1] - close) / ATR(ATR length) <= near ATR multiple
Short: DownTrend AND (close - Lowest(low, breakout lookback)[1]) / ATR(ATR length) <= near ATR multiple
Calculation: LongStop = entry price - initial stop ATR multiple * ATR(ATR length) if bar is entry bar, else max(LongStop[1], highest high from entry bar to current bar - trail ATR multiple * ATR(ATR length))
Calculation: ShortStop = entry price + initial stop ATR multiple * ATR(ATR length) if bar is entry bar, else min(ShortStop[1], lowest low from entry bar to current bar + trail ATR multiple * ATR(ATR length))
Exit: long, low <= LongStop[1]
Exit: short, high >= ShortStop[1]