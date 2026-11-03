Calculation: Calculation-period body low/high = the running minimum/maximum of max(open, close)/min(open, close) within the selected higher timeframe period, aggregated from chart bars.
Calculation: Period midpoint time = half the expected period length, estimated from the number of chart bars in the previous period.
Calculation: Bullish fair value gap = a gap where the current low is above the high two chart bars earlier, with the previous close above the previous low plus an ATR-based threshold.
Calculation: Bearish fair value gap = a gap where the current high is below the low two chart bars earlier, with the previous close below the previous high minus an ATR-based threshold.
Long: After the period midpoint, low < the prior chart bar's running calculation-period body low AND min(open, close) >= that low AND the bar is not the first bar of a new period.
Short: After the period midpoint, high > the prior chart bar's running calculation-period body high AND max(open, close) <= that high AND the bar is not the first bar of a new period.
Long: A confirmed chart-timeframe pivot low has a lower wick greater than half its candle range.
Short: A confirmed chart-timeframe pivot high has an upper wick greater than half its candle range.
Long: A bullish fair value gap exists AND low < its upper boundary AND close > its upper boundary.
Short: A bearish fair value gap exists AND high > its lower boundary AND close < its lower boundary.
Long: Two bars ago closed below its open AND its low was at or below the running calculation-period body low as of the prior chart bar; the previous bar's low is below the two-bars-ago low AND its close is above that low; current close > current open AND current close > previous high.
Short: Two bars ago closed above its open AND its high was at or above the running calculation-period body high as of the prior chart bar; the previous bar's high is above the two-bars-ago high AND its close is below that high; current close < current open AND current close < previous low.
Short: Previous bar closed below its open AND its low was at or below the running calculation-period body low as of the preceding chart bar; current close < previous low.
Long: Previous bar closed above its open AND its high was at or above the running calculation-period body high as of the preceding chart bar; current close > previous high.
Long: Previous bar closed below its open AND its low was at or below the running calculation-period body low as of the preceding chart bar; current low >= previous low AND current close > current open AND current close > previous high.
Short: Previous bar closed above its open AND its high was at or above the running calculation-period body high as of the preceding chart bar; current high <= previous high AND current close < current open AND current close < previous low.