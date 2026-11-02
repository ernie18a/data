Calculation: Opening range = the highest high and lowest low of chart bars in the configured opening session, using America/New_York time; reset on each new day and consider the range ready after the session ends.
Calculation: Previous-day high and low = high and low of the last completed higher-timeframe daily bar.
Calculation: Confirmed pivot high or low = a high or low with the configured number of chart bars on each side confirming the pivot; update the latest pivot when its right-side bars complete.
Calculation: Resistance or support trendline = the line through the two latest confirmed pivot highs or lows, respectively, extrapolated to the current and previous chart bars; replace it when a new pivot of that kind is confirmed.
Calculation: Bullish structure break = close > latest confirmed pivot high AND previous close <= that same pivot high. Bearish structure break = close < latest confirmed pivot low AND previous close >= that same pivot low.
Calculation: Bullish trendline break = close > current resistance trendline AND previous close <= the same trendline at the previous bar. Bearish trendline break = close < current support trendline AND previous close >= the same trendline at the previous bar.
Calculation: Bullish sweep = opening range ready AND ((low < previous-day low AND close > previous-day low) OR (low < opening-range low AND close > opening-range low)). Bearish sweep = opening range ready AND ((high > previous-day high AND close < previous-day high) OR (high > opening-range high AND close < opening-range high)).
Calculation: Bullish fair value gap = low > high two bars ago AND low minus that high >= ATR times the gap-size multiplier. Bearish fair value gap = high < low two bars ago AND that low minus high >= ATR times the gap-size multiplier.
Calculation: Bullish inverted gap = close > the upper boundary of a stored bearish fair value gap. Bearish inverted gap = close < the lower boundary of a stored bullish fair value gap. Store up to a configured maximum number of the newest gaps per side; remove a gap when inverted or when its age exceeds its configured lifetime, checking inversion before expiry.
Calculation: Bullish order-block trigger = bullish structure break AND close > open AND high minus low >= ATR times the displacement multiplier. Bearish order-block trigger = bearish structure break AND close < open AND high minus low >= ATR times the displacement multiplier.
Calculation: Bullish opening-range retest = a bullish opening-range break occurred on an earlier bar within the confirmation-memory lookback AND low <= opening-range high plus a price tolerance AND close > opening-range high. A bullish break requires opening range ready AND close > opening-range high AND previous close <= that same high. Bearish opening-range retest = a bearish break occurred on an earlier bar within the confirmation-memory lookback AND high >= opening-range low minus a price tolerance AND close < opening-range low. A bearish break requires opening range ready AND close < opening-range low AND previous close >= that same low. Store the latest break independently for each side and clear it after its first retest.
Calculation: Session VWAP = cumulative volume-weighted mean of (high + low + close) / 3 since the daily session anchor. Session VWAP deviation = the square root of the volume-weighted variance of that price since the daily reset.
Calculation: Flow score = the sum of points assigned by ordered thresholds to relative volume, bar range divided by ATR, absolute candle body divided by bar range, and absolute distance of close from session VWAP divided by session VWAP deviation. Relative volume is volume divided by its SMA. Use zero for a ratio whose denominator is nonpositive; assign higher point values to higher thresholds.
Calculation: Directional confluence score = the count of these seven independently evaluated conditions for the side: a same-side sweep within sweep memory; a same-side trendline break within confirmation memory; a same-side structure break within structure memory; close above session VWAP for bullish or below it for bearish; close above open for bullish or below open for bearish AND flow score >= the strong-flow threshold; a same-side fair value gap, inverted gap, or order-block trigger within confirmation memory; a same-side opening-range retest within confirmation memory OR opening range ready AND close beyond its corresponding boundary. Each memory includes the current bar and events at exactly the configured age.
Long: bullish sweep = true.
Short: bearish sweep = true.
Long: bullish trendline break = true.
Short: bearish trendline break = true.
Long: bullish structure break = true.
Short: bearish structure break = true.
Long: bullish fair value gap = true.
Short: bearish fair value gap = true.
Long: bullish inverted gap = true.
Short: bearish inverted gap = true.
Long: bullish order-block trigger = true AND at least one bearish candle exists in the configured preceding search lookback.
Short: bearish order-block trigger = true AND at least one bullish candle exists in the configured preceding search lookback.
Long: close > open AND flow score >= the minimum flow threshold AND bars since the previous bullish flow marking >= the flow cooldown, or no previous bullish flow marking exists.
Short: close < open AND flow score >= the minimum flow threshold AND bars since the previous bearish flow marking >= the flow cooldown, or no previous bearish flow marking exists.
Long: bullish confluence score >= the minimum confirmation threshold AND bullish confluence score > bearish confluence score.
Short: bearish confluence score >= the minimum confirmation threshold AND bearish confluence score > bullish confluence score.