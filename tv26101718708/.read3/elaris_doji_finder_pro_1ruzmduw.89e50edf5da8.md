Calculation: Body percentage = if high > low then 100 * abs(close - open) / (high - low) else 100
Calculation: Upper wick percentage = if high > low then 100 * (high - max(open, close)) / (high - low) else 0
Calculation: Lower wick percentage = if high > low then 100 * (min(open, close) - low) / (high - low) else 0
Calculation: Dragonfly doji = Body percentage <= maximum body percentage AND Lower wick percentage >= minimum long-wick percentage AND Upper wick percentage <= maximum small-wick percentage
Calculation: Gravestone doji = Body percentage <= maximum body percentage AND Upper wick percentage >= minimum long-wick percentage AND Lower wick percentage <= maximum small-wick percentage
Calculation: Long-legged doji = Body percentage <= maximum body percentage AND Upper wick percentage >= minimum long-wick percentage AND Lower wick percentage >= minimum long-wick percentage
Calculation: Neutral doji = Body percentage <= maximum body percentage AND NOT Dragonfly doji AND NOT Gravestone doji AND NOT Long-legged doji
Calculation: Near support = a latest confirmed pivot low using the pivot lookback on each side exists AND abs(low - that pivot low) <= ATR(ATR lookback) * support/resistance distance
Calculation: Near resistance = a latest confirmed pivot high using the pivot lookback on each side exists AND abs(high - that pivot high) <= ATR(ATR lookback) * support/resistance distance
Calculation: Bullish context = Dragonfly doji OR Near support OR close > open
Calculation: Bearish context = Gravestone doji OR Near resistance OR close < open
Calculation: Qualified doji signal = (dragonfly type enabled AND Dragonfly doji) OR (gravestone type enabled AND Gravestone doji) OR (long-legged type enabled AND Long-legged doji) OR (neutral type enabled AND Neutral doji), AND high - low >= ATR(ATR lookback) * minimum candle-range-to-ATR ratio, AND (volume filter disabled OR volume >= SMA(volume, volume lookback) * volume multiplier), AND (support/resistance filter disabled OR Near support OR Near resistance), AND (trend filter disabled OR (Bullish context AND close < EMA(close, trend lookback)) OR (Bearish context AND close > EMA(close, trend lookback)) OR Long-legged doji), AND (close-confirmation disabled OR the chart bar is complete)
Long: Qualified doji signal AND ((Bullish context AND NOT Bearish context) OR Dragonfly doji)
Short: Qualified doji signal AND ((Bearish context AND NOT Bullish context) OR Gravestone doji)