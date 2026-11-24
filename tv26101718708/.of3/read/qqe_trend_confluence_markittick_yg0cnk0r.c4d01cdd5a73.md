Calculation: Filtered price source = selected chart price source processed by the selected adaptive filter using its lookback; available calculations include SMA, EMA, RMA, two cascaded WMAs, three cascaded VWMAs, HMA, LLAMA, and Kalman filter, or the unchanged source.
Calculation: LLAMA(source, lookback) = SMA(source, lookback) + (source - source[lookback]) / lookback × (lookback / 2)
Calculation: Primary QQE = QQE(filtered price source, shared RSI lookback, primary smoothing lookback, primary factor), returning smoothed RSI and trailing level
Calculation: Secondary QQE = QQE(filtered price source, same RSI lookback, longer secondary smoothing lookback, separate secondary factor), returning smoothed RSI and trailing level
Calculation: QQE distance = primary QQE smoothed RSI - primary QQE trailing level
Long: Primary QQE smoothed RSI crosses above its trailing level between the last two completed chart bars AND (secondary confirmation disabled OR secondary QQE smoothed RSI > its trailing level on the last completed chart bar) AND (ADX filter disabled OR ADX using the same lookback for DI and ADX smoothing >= threshold on the last completed chart bar) AND (higher-timeframe filter disabled OR primary QQE calculated on T1 bars has smoothed RSI > its trailing level on the last completed T1 bar, sampled on chart bars)
Short: Primary QQE smoothed RSI crosses below its trailing level between the last two completed chart bars AND (secondary confirmation disabled OR secondary QQE smoothed RSI < its trailing level on the last completed chart bar) AND (ADX filter disabled OR ADX using the same lookback for DI and ADX smoothing >= threshold on the last completed chart bar) AND (higher-timeframe filter disabled OR primary QQE calculated on T1 bars has smoothed RSI < its trailing level on the last completed T1 bar, sampled on chart bars)
Long: Primary QQE smoothed RSI > its trailing level on the current chart bar
Long: Histogram enabled AND QQE distance = 0 on the current chart bar
Short: Primary QQE smoothed RSI <= its trailing level on the current chart bar
Long: Secondary confirmation enabled AND secondary QQE smoothed RSI > its trailing level on the last completed chart bar
Short: Secondary confirmation enabled AND secondary QQE smoothed RSI < its trailing level on the last completed chart bar
Long: Higher-timeframe filter enabled AND primary QQE calculated on T1 bars has smoothed RSI > its trailing level on the last completed T1 bar, sampled on chart bars
Short: Higher-timeframe filter enabled AND primary QQE calculated on T1 bars has smoothed RSI <= its trailing level on the last completed T1 bar, sampled on chart bars
Long: +DI using the ADX lookback > -DI using the ADX lookback on the current chart bar
Short: +DI using the ADX lookback <= -DI using the ADX lookback on the current chart bar
Calculation: Planned entry price = close[1] on the signal chart bar
Calculation: Plan risk distance = ATR(lookback) on the signal chart bar × stop-distance multiple
Calculation: Long stop = planned entry price - plan risk distance
Calculation: Short stop = planned entry price + plan risk distance
Calculation: First, second, and third target ratios are separate risk/reward parameters ordered from lowest to highest
Calculation: Long target 1 = planned entry price + plan risk distance × first target ratio
Calculation: Long target 2 = planned entry price + plan risk distance × second target ratio
Calculation: Long target 3 = planned entry price + plan risk distance × third target ratio
Calculation: Short target 1 = planned entry price - plan risk distance × first target ratio
Calculation: Short target 2 = planned entry price - plan risk distance × second target ratio
Calculation: Short target 3 = planned entry price - plan risk distance × third target ratio
Calculation: Active trade plan = on each qualifying signal, when trade levels are enabled and the signal is not blocked by lock on the last chart bar, store the side and that signal's entry, risk, stop, and targets; replace on a later eligible signal and clear after the stop or third target is hit
Exit: long, trade levels enabled AND active plan is long AND low <= long stop
Exit: long, trade levels enabled AND active plan is long AND high >= long target 1
Exit: long, trade levels enabled AND active plan is long AND high >= long target 2
Exit: long, trade levels enabled AND active plan is long AND high >= long target 3
Exit: short, trade levels enabled AND active plan is short AND high >= short stop
Exit: short, trade levels enabled AND active plan is short AND low <= short target 1
Exit: short, trade levels enabled AND active plan is short AND low <= short target 2
Exit: short, trade levels enabled AND active plan is short AND low <= short target 3