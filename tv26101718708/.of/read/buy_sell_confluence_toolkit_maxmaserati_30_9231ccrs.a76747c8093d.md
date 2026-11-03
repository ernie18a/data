Calculation: KDJ = raw K is 100 × (close − lowest low) / max(highest high − lowest low, 1e-10) over a common lookback; K is the SMA of raw K, D is the SMA of K, and J is 3 × K − 2 × D.
Calculation: Bollinger %B = 100 × (close − lower Bollinger Band) / (upper Bollinger Band − lower Bollinger Band); use 50 when band width is not positive.
Calculation: Confluence percentages = separately sum the weights of bullish and bearish component states and divide each sum by the sum of all component weights, including neutral components; use zero when the total weight is zero. The Bollinger weight is zero when its score is disabled. Component states are: MACD bullish when MACD line > signal line AND histogram > 0, bearish when MACD line < signal line AND histogram < 0; KDJ bullish when K > D AND J > K, bearish when K < D AND J < K; RSI bullish when RSI > 50 AND RSI < overbought threshold AND RSI > oversold threshold, bearish when RSI < 50 AND RSI < overbought threshold AND RSI > oversold threshold; CCI of typical price bullish when CCI > 0 AND CCI < overbought threshold AND CCI > oversold threshold, bearish when CCI < 0 AND CCI < overbought threshold AND CCI > oversold threshold; anchored VWAP bullish when close > VWAP, bearish when close < VWAP; selected moving average of the selected price source bullish when close > moving average AND moving average > its value two bars earlier, bearish when close < moving average AND moving average <= its value two bars earlier; volume bullish when close > open AND volume qualifies for any configured mid, whale, or climax tier, bearish when close < open AND volume qualifies for any of those tiers; Bollinger bullish when enabled AND %B > 60, bearish when enabled AND %B < 40. All other component states are neutral. Each volume tier requires volume >= its multiplier × volume SMA; the whale tier excludes the climax tier and the mid tier excludes both higher tiers.
Calculation: Pre-gate events = a bullish event occurs when bullish confluence percentage >= its threshold AND its previous-bar value < that threshold AND the optional moving-average filter is disabled or close > the selected moving average AND the previous pre-gate event was not bullish; a bearish event uses bearish percentage and threshold, close < moving average for the optional filter, and a previous event that was not bearish. Initially there is no previous event. Update the event state before applying the price gate, with bullish priority if both events occur on the same bar.
Calculation: ATR trail = on a bullish pre-gate event set the trail to low − ATR × multiplier and direction bullish; otherwise, on a bearish pre-gate event set it to high + ATR × multiplier and direction bearish. On subsequent bars without an event, a bullish trail is max(previous trail, low − ATR × multiplier), and a bearish trail is min(previous trail, high + ATR × multiplier). It is unavailable before the first event.
Long: bullish pre-gate event AND (price gate disabled OR selected gate unavailable OR close > selected gate), where the selected gate is anchored VWAP, ATR trail, or Bollinger basis.
Short: bearish pre-gate event AND (price gate disabled OR selected gate unavailable OR close < selected gate), where the selected gate is anchored VWAP, ATR trail, or Bollinger basis.
Long: MACD line > signal line AND histogram > 0.
Short: MACD line < signal line AND histogram < 0.
Long: K > D AND J > K.
Short: K < D AND J < K.
Long: RSI > 50 AND RSI < overbought threshold AND RSI > oversold threshold.
Short: RSI < 50 AND RSI < overbought threshold AND RSI > oversold threshold.
Long: CCI of typical price > 0 AND CCI < overbought threshold AND CCI > oversold threshold.
Short: CCI of typical price < 0 AND CCI < overbought threshold AND CCI > oversold threshold.
Long: close > anchored VWAP.
Short: close < anchored VWAP.
Short: anchored VWAP is available AND close <= anchored VWAP.
Long: close > selected moving average AND selected moving average > its value two bars earlier.
Short: close < selected moving average AND selected moving average <= its value two bars earlier.
Short: selected moving average is available AND (close <= selected moving average OR selected moving average <= its value two bars earlier).
Long: Bollinger score enabled AND Bollinger %B > 60.
Short: Bollinger score enabled AND Bollinger %B < 40.
Long: close > open AND volume qualifies for a mid, whale, or climax tier.
Short: close < open AND volume qualifies for a mid, whale, or climax tier.
Long: close > previous high AND close > open.
Short: close < previous low AND close < open.
Long: low < previous low AND close >= open AND NOT (close > previous high AND close > open) AND NOT (close < previous low AND close < open).
Short: high > previous high AND close <= open AND NOT (close > previous high AND close > open) AND NOT (close < previous low AND close < open) AND NOT (low < previous low AND close >= open).
Long: close >= open AND NOT (close > previous high AND close > open) AND NOT (close < previous low AND close < open) AND NOT (low < previous low AND close >= open) AND NOT (high > previous high AND close <= open).
Short: close < open AND NOT (close > previous high AND close > open) AND NOT (close < previous low AND close < open) AND NOT (low < previous low AND close >= open) AND NOT (high > previous high AND close <= open).
Long: most recent pre-gate event is bullish.
Short: most recent pre-gate event is bearish.
Long: bullish confluence percentage >= bearish confluence percentage.
Short: bearish confluence percentage > bullish confluence percentage.