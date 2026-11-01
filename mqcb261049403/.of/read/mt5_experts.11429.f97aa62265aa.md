Calculation: Trend state = On the first eligible bar after the lookback history, bullish if close > open, otherwise bearish. On each subsequent bar, if the preceding completed bar's state is bullish, remain bullish if the selected bullish price is greater than at least one low in the preceding lookback bars; otherwise become bearish. If the preceding completed bar's state is bearish, remain bearish if the selected bearish price is less than at least one high in the preceding lookback bars; otherwise become bullish. The selected prices are either close for both comparisons or low for the bullish comparison and high for the bearish comparison. Calculate on the chart timeframe for indicator markings and on a configurable higher or lower timeframe for the expert's decisions, using either its still-forming bar or a configurable completed bar and the preceding bar.
Long: Chart-timeframe trend state = bullish
Short: Chart-timeframe trend state = bearish
Long: Selected expert-timeframe trend state = bullish AND preceding expert-timeframe trend state = bearish AND position is flat
Short: Selected expert-timeframe trend state = bearish AND preceding expert-timeframe trend state = bullish AND position is flat
Exit: long, selected expert-timeframe trend state = bearish
Exit: short, selected expert-timeframe trend state = bullish
Exit: long, low <= entry price minus enabled stop-loss distance OR high >= entry price plus enabled take-profit distance
Exit: short, high >= entry price plus enabled stop-loss distance OR low <= entry price minus enabled take-profit distance