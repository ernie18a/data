Calculation: Longer-lookback SuperTrend trend = ATR-based bands from (high + low) / 2, with lower band = midpoint − multiplier × ATR and upper band = midpoint + multiplier × ATR; trail the lower band upward using the greater of its raw value and prior lower band when prior close is above that prior band, otherwise reset it to its raw value; trail the upper band downward using the lesser of its raw value and prior upper band when prior close is below that prior band, otherwise reset it; bullish if close > prior upper band, bearish if close < prior lower band, otherwise retain prior direction
Calculation: Shorter-lookback SuperTrend trend = same calculation as the longer-lookback SuperTrend, using a shorter lookback
Calculation: VIX mean = simple moving average of VIX close
Calculation: VIX EMA = exponential moving average of VIX close
Calculation: VIX close = close of the last completed bar on a timeframe higher than the chart timeframe
Calculation: Four long profit targets = entry price × (1 + four progressively larger positive target percentages)
Calculation: Four short profit targets = entry price × (1 − four progressively larger positive target percentages)
Calculation: Long stop = entry price × (1 − stop-loss percentage)
Calculation: Short stop = entry price × (1 + stop-loss percentage)
Long: longer-lookback SuperTrend bullish AND shorter-lookback SuperTrend bullish AND VIX close > VIX mean AND position is flat or short
Short: longer-lookback SuperTrend bearish AND shorter-lookback SuperTrend bearish AND VIX close > VIX EMA AND position is flat or long
Exit: long, longer-lookback SuperTrend bearish OR shorter-lookback SuperTrend bearish OR high ≥ any long profit target OR low ≤ long stop
Exit: short, longer-lookback SuperTrend bullish OR shorter-lookback SuperTrend bullish OR low ≤ any short profit target OR high ≥ short stop