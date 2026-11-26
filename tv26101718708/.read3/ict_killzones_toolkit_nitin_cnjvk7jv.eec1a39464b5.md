Calculation: Active killzone = current bar datetime is within an enabled configured session in the script's session timezone AND the chart timeframe multiplier is no greater than the configured maximum killzone timeframe multiplier
Calculation: Swing state starts high; on each bar it becomes high if high[swing lookback] > Highest(high, swing lookback), otherwise it becomes low if low[swing lookback] < Lowest(low, swing lookback), otherwise it holds; record high[swing lookback] or low[swing lookback] as the swing high or low when the state changes to high or low, respectively
Calculation: Candle bounds = max(open, close) and min(open, close) when body mode is selected; otherwise high and low
Calculation: Bullish order block = the candle with the minimum configured lower bound after the eligible swing-high bar through its qualifying break bar; the block spans that candle's configured bounds
Calculation: Bearish order block = the candle with the maximum configured upper bound after the eligible swing-low bar through its qualifying break bar; the block spans that candle's configured bounds
Calculation: Bullish-block mitigation price = min(open[1], close[1]) in closing-price mode or min(open[1], low[1]) in wick mode
Calculation: Bearish-block mitigation price = max(open[1], close[1]) in closing-price mode or max(open[1], high[1]) in wick mode
Long: Active killzone AND close[1] > the latest swing high formed since the current killzone began AND that swing high has not already produced a bullish order block
Short: Active killzone AND close[1] < the latest swing low formed since the current killzone began AND that swing low has not already produced a bearish order block
Short: Any unmitigated bullish order block exists AND bullish-block mitigation price < its lower bound
Long: Any unmitigated bearish order block exists AND bearish-block mitigation price > its upper bound
Long: Active killzone AND low - high[2] > ATR(ATR lookback) * FVG width multiplier AND low > high[2] AND close[1] > high[2] AND NOT (low > high[1] OR low[1] > high[2])
Short: Active killzone AND low[2] - high > ATR(ATR lookback) * FVG width multiplier AND high < low[2] AND close[1] < low[2] AND NOT (high < low[1] OR high[1] < low[2])
Long: Active killzone AND close[1] > the latest confirmed Pivot High(pivot lookback, pivot lookback) AND that pivot has not already produced a bullish market structure shift
Short: Active killzone AND close[1] < the latest confirmed Pivot Low(pivot lookback, pivot lookback) AND that pivot has not already produced a bearish market structure shift