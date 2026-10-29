Calculation: Strong candle = abs(close − open) / max(high − low, minimum price increment) meets a configurable minimum.
Calculation: Bullish trend = the latest completed close exceeds the preceding completed close on each of the daily, middle, and shortest higher timeframes; bearish trend = it is below on each.
Calculation: Bullish structure = the latest completed close on each of the middle and shortest higher timeframes exceeds that timeframe’s highest high over a configurable lookback ending two bars earlier; bearish structure = it is below the corresponding lowest low. These timeframes are higher than the chart timeframe; use completed bars.
Calculation: Ranging = either the highs or the lows of each successive pair among the last three completed middle higher-timeframe bars differ by less than a configurable tolerance.
Calculation: ICC levels = the high, low, and midpoint of a configurable prior completed higher-timeframe bar; that timeframe is higher than the chart timeframe.
Calculation: Local swing high/low = the highest high / lowest low over a configurable lookback of chart bars, excluding the current bar.
Calculation: Active BOS level = the latest chart-bar close crossover above the local swing high or crossunder below the local swing low, retained until the close moves beyond that level by twice a configurable invalidation distance or an opposite break occurs.
Calculation: Active BOS fair value gap = after an active break, a three-bar gap in the break direction; it remains active until price breaches its far boundary or the break becomes inactive.
Calculation: Session range = the highest high and lowest low during the configured opening-range window, available after that window ends; each direction can signal once per range.
Long: On an enabled entry chart timeframe, during an enabled session, not ranging, bullish trend and bullish structure, and (low <= ICC low + configurable touch tolerance AND close < ICC midpoint AND close > open AND strong candle).
Short: On an enabled entry chart timeframe, during an enabled session, not ranging, bearish trend and bearish structure, and (high >= ICC high − configurable touch tolerance AND close > ICC midpoint AND close < open AND strong candle).
Long: On an enabled entry chart timeframe, during an enabled session, not ranging, bullish trend and bullish structure, and active bullish break, and ((low <= active BOS level + configurable touch tolerance AND close >= active BOS level − configurable touch tolerance) OR (low <= active bullish gap top AND close >= active bullish gap bottom)), and close > open and strong candle.
Short: On an enabled entry chart timeframe, during an enabled session, not ranging, bearish trend and bearish structure, and active bearish break, and ((high >= active BOS level − configurable touch tolerance AND close <= active BOS level + configurable touch tolerance) OR (high >= active bearish gap bottom AND close <= active bearish gap top)), and close < open and strong candle.
Long: Bullish trend AND chart close crosses above the local swing high.
Short: Bearish trend AND chart close crosses below the local swing low.
Long: After the configured daily accumulation bars, before either range boundary has been swept, the chart high exceeds the accumulation high; only one sweep is recorded per day.
Short: After the configured daily accumulation bars, before either range boundary has been swept, the chart low falls below the accumulation low; only one sweep is recorded per day.
Long: The daily accumulation low has been swept, distribution has not yet occurred, and close > accumulation low AND close > open AND strong candle.
Short: The daily accumulation high has been swept, distribution has not yet occurred, and close < accumulation high AND close < open AND strong candle.
Long: During the configured Asia session, the Asia low is swept by more than a configurable tolerance; before either Asia boundary has been swept.
Short: During the configured London or New York session, the Asia high is swept by more than a configurable tolerance; before either Asia boundary has been swept.
Long: The Asia low has been swept, and close > Asia low AND close > open AND strong candle.
Short: The Asia high has been swept, and close < Asia high AND close < open AND strong candle.
Long: The opening range is complete, its long signal has not occurred, and chart close crosses above its high.
Short: The opening range is complete, its short signal has not occurred, and chart close crosses below its low.