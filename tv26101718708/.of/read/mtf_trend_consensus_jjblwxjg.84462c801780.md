Calculation: Timeframe direction = bullish when the shorter-period EMA of close is greater than the longer-period EMA of close; bearish otherwise. Calculate the EMAs from closes shifted back one bar. Apply this to the chart timeframe and each selected comparison timeframe; on a higher timeframe, use the last completed bar, and on a lower timeframe, use the bar preceding the first lower-timeframe bar in the chart bar.
Calculation: Overall direction = the majority timeframe direction across the chart timeframe and selected comparison timeframes; the chart timeframe direction breaks ties.
Calculation: Consensus score = the rounded percentage of the sum of ADX weights for timeframes agreeing with the overall direction divided by the sum of ADX weights for all included timeframes. Use the same ADX period and smoothing period; replace unavailable ADX values with a fallback weight. On the chart timeframe use the current bar; on a higher timeframe use the bar still forming; on a lower timeframe use the first lower-timeframe bar in the chart bar.
Long: Any included timeframe's shorter-period EMA > its longer-period EMA.
Short: Any included timeframe's shorter-period EMA <= its longer-period EMA.
Long: Any included timeframe's shifted close > its longer-period EMA of shifted close.
Short: Any included timeframe's shifted close <= its longer-period EMA of shifted close.
Long: Overall direction is bullish AND consensus score >= consensus threshold.
Short: Overall direction is bearish AND consensus score >= consensus threshold.