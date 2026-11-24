Calculation: bullish Renko streak = prior bullish Renko streak + 1 when Renko close > Renko open; otherwise 0
Calculation: bearish Renko streak = prior bearish Renko streak + 1 when Renko close < Renko open; otherwise 0
Calculation: bullish MTF score = count of T1, T2, and T3 comparisons where chart-bar close > SMA(close, MTF lookback, that timeframe, last completed bar), with each timeframe value sampled on chart bars
Calculation: bearish MTF score = count of T1, T2, and T3 comparisons where chart-bar close < SMA(close, MTF lookback, that timeframe, last completed bar), with each timeframe value sampled on chart bars
Calculation: bullish entry signal = first bar of a bullish Renko streak AND (MTF filter disabled OR bullish MTF score >= tier threshold) AND (session filter disabled OR chart-bar time is within the configured session)
Calculation: bearish entry signal = first bar of a bearish Renko streak AND (MTF filter disabled OR bearish MTF score >= tier threshold) AND (session filter disabled OR chart-bar time is within the configured session)
Long: bullish Renko streak > 0
Short: bearish Renko streak > 0
Long: bullish MTF score >= tier threshold
Short: bearish MTF score >= tier threshold
Long: bullish entry signal
Short: bearish entry signal
Long: low < lowest(low[1], sweep lookback) AND close > lowest(low[1], sweep lookback) AND close > open
Short: high > highest(high[1], sweep lookback) AND close < highest(high[1], sweep lookback) AND close < open
Calculation: upper-wick cluster count = 0 without an upper wick; with an upper wick, set the count to 1 and the reference to high if no reference exists or abs(high - reference) > ATR(ATR lookback) * wick proximity parameter; otherwise increment the count and retain the reference
Calculation: lower-wick cluster count = 0 without a lower wick; with a lower wick, set the count to 1 and the reference to low if no reference exists or abs(low - reference) > ATR(ATR lookback) * wick proximity parameter; otherwise increment the count and retain the reference
Short: upper-wick cluster count >= wick-count threshold
Long: lower-wick cluster count >= wick-count threshold
Long: bullish entry signal AND Renko bar volume <= SMA(Renko bar volume, volume lookback)
Short: bearish entry signal AND Renko bar volume <= SMA(Renko bar volume, volume lookback)
Calculation: stored order-block zone = [min(Renko open, Renko close), max(Renko open, Renko close)] on each entry signal when order-block storage is enabled; retain only the configured maximum
Calculation: stop level = for a long, the bottom of the nearest stored order block except the newest whose top is below entry price, if structural stops are enabled, more than one block is stored, and a qualifying block exists; otherwise entry price - ATR(ATR lookback) at the signal bar * stop multiple. For a short, use the top of the nearest stored order block except the newest whose bottom is above entry price under the same conditions; otherwise entry price + ATR(ATR lookback) at the signal bar * stop multiple
Calculation: profit targets = for a long, entry price + ATR(ATR lookback) at the signal bar * each of the separate target multiples; for a short, entry price - ATR(ATR lookback) at the signal bar * each of the separate target multiples; hold the levels fixed for the position
Calculation: trailing stop = when Renko close > Renko open, max(previous trailing stop, Renko open), initialized to Renko open; when Renko close < Renko open, min(previous trailing stop, Renko close), initialized to Renko close; otherwise undefined
Exit: long, confirmed chart-bar close < stop level OR chart-bar high >= first profit target OR chart-bar high >= second profit target OR chart-bar high >= third profit target OR chart-bar low <= trailing stop
Exit: short, confirmed chart-bar close > stop level OR chart-bar low <= first profit target OR chart-bar low <= second profit target OR chart-bar low <= third profit target OR chart-bar high >= trailing stop