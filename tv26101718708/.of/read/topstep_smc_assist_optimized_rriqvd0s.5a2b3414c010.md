Calculation: Bullish HTF score = weighted points for higher-timeframe close above its EMA, EMA slope above an ATR-scaled threshold, bullish displacement, bullish volume flow, bullish FVG, bullish CISD, and prime session; subtract penalties for midday, HTF overextension, and hard-bad conditions; floor at zero. Use the current higher-timeframe bar while forming, otherwise its latest available bar.
Calculation: Bearish HTF score = weighted points for higher-timeframe close below its EMA, EMA slope below a negative ATR-scaled threshold, bearish displacement, bearish volume flow, bearish FVG, bearish CISD, and prime session; subtract the same penalties as for the bullish score; floor at zero. Use the current higher-timeframe bar while forming, otherwise its latest available bar.
Calculation: HTF overextension = absolute distance between higher-timeframe close and its EMA exceeds higher-timeframe ATR times the configured extension limit.
Calculation: Hard-bad conditions = flat chart-timeframe EMA slope OR low volatility (ATR below its longer-lookback ATR average times a threshold) OR compression (longer-lookback high-low range below ATR times a threshold) OR weak body OR excessive wick on both the current and prior bar.
Calculation: Bullish and bearish HTF setup = matching HTF trend AND matching score meets the configured minimum AND (score is within the configured sweet-spot range and exceeds the opposite score OR score exceeds the sweet-spot ceiling, is not overextended, and exceeds the opposite score) AND (countertrend blocking is disabled OR matching score exceeds opposite score by the configured dominance buffer).
Calculation: Bullish and bearish micro confirmation score = count of matching lower-timeframe FVG, CISD, and order-block conditions. Use the latest available lower-timeframe bar within the chart bar; it is completed when the chart bar is confirmed.
Calculation: Bullish/bearish micro confirmation = matching micro score meets the lower threshold during the configured NY kill zone, otherwise it meets the higher threshold.
Calculation: Bullish/bearish chart-timeframe trigger = (matching trend (close above/below EMA), matching EMA slope (above/below an ATR-scaled threshold), and matching flow OR strong matching pressure) OR (matching sweep OR matching FVG OR matching CISD OR matching order block) AND matching flow OR matching micro confirmation.
Calculation: Good follow-through = healthy volatility (ATR above its longer-lookback ATR average times a threshold) OR range expansion (shorter-lookback high-low range above ATR times a threshold) OR within the configured NY kill zone.
Calculation: Entry quality = body/range ratio meets its configured minimum AND good follow-through AND NOT hard-bad conditions AND NOT HTF overextension.
Calculation: HTF bullish/bearish score components use higher-timeframe bars, which are higher than the chart timeframe; use the current higher-timeframe bar while forming, otherwise its latest available bar. HTF EMA and ATR use the same lookbacks as their chart-timeframe counterparts.
Calculation: Long target = entry price + (entry price - signal-bar low + ATR-based stop offset) times configured reward/risk ratio; long stop = signal-bar low minus ATR-based stop offset.
Calculation: Short target = entry price - (signal-bar high - entry price + ATR-based stop offset) times configured reward/risk ratio; short stop = signal-bar high plus ATR-based stop offset.
Long: chart bar is confirmed when confirmation is enabled AND within the configured session AND bullish HTF setup AND bullish chart-timeframe trigger AND entry quality.
Short: chart bar is confirmed when confirmation is enabled AND within the configured session AND bearish HTF setup AND bearish chart-timeframe trigger AND entry quality.
Long: current low is below the most recent confirmed swing low AND current close is above that swing low.
Short: current high is above the most recent confirmed swing high AND current close is below that swing high.
Long: current low is above the high two chart bars ago.
Short: current high is below the low two chart bars ago.
Long: prior bar is bearish AND current close is above prior high.
Short: prior bar is bullish AND current close is below prior low.
Long: current bar is bullish AND relative volume exceeds its configured pressure threshold AND close is above EMA.
Short: current bar is bearish AND relative volume exceeds its configured pressure threshold AND close is below EMA.
Long: bullish HTF score meets the forecast threshold AND exceeds bearish HTF score.
Short: bearish HTF score meets the forecast threshold AND exceeds bullish HTF score.
Exit: Long, current high >= long target OR current low <= long stop OR bars since entry >= configured timeout.
Exit: Short, current low <= short target OR current high >= short stop OR bars since entry >= configured timeout.