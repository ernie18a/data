Calculation: Bullish alignment score = count of the four timeframe RSI values at or above the RSI midpoint plus count of the four timeframe EMA values below the chart close; use the same RSI length and the same EMA length across timeframes. For a higher timeframe, use the last completed bar; for a lower timeframe, use the last completed intrabar within the chart bar.
Calculation: Anchored VWAP = cumulative sum of chart-bar source price multiplied by volume divided by cumulative volume since the start of the anchor period; use shorter and longer calendar anchor periods.
Long: Bullish alignment score >= bullish score threshold
Short: Bullish alignment score < neutral score threshold
Short: Bullish alignment score <= bearish alert score threshold
Long: RSI on any of the four timeframes <= oversold threshold
Short: RSI on any of the four timeframes >= overbought threshold
Long: RSI on any of the four timeframes >= midpoint AND RSI on that timeframe < overbought threshold
Long: Chart close > EMA on any of the four timeframes
Short: Chart close <= EMA on any of the four timeframes
Long: RSI on any of the four timeframes >= midpoint AND chart close > EMA on the same timeframe
Short: RSI on any of the four timeframes < midpoint AND chart close < EMA on the same timeframe
Long: Chart close > shorter-anchor VWAP OR chart close > longer-anchor VWAP
Short: Chart close <= shorter-anchor VWAP OR chart close <= longer-anchor VWAP
Long: RSI on the longest configured timeframe crosses below the oversold threshold
Short: RSI on the longest configured timeframe crosses above the overbought threshold
Long: Chart close crosses above shorter-anchor VWAP OR chart close crosses above longer-anchor VWAP
Short: Chart close crosses below shorter-anchor VWAP OR chart close crosses below longer-anchor VWAP