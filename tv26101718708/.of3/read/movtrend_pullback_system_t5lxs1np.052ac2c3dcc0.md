Calculation: Regression trend line = LinearRegression(close, trend lookback)
Calculation: Regression slope = Regression trend line - Regression trend line[slope lookback bars ago]
Calculation: ATR envelope = Regression trend line ± ATR(ATR lookback) × band multiplier
Calculation: Fair-value-gap proximity = close is within ATR(ATR lookback) × proximity multiplier of any of the latest retained chart-timeframe three-bar gap zones, where a bullish zone is [high[2], low] when low > high[2], and a bearish zone is [high, low[2]] when high < low[2]; retain up to the zone-count parameter
Calculation: ATR-regime test = PercentRank(ATR(ATR lookback), regime lookback) >= minimum percentile
Calculation: Volume test = volume is available AND SMA(volume, volume lookback) is available AND SMA(volume, volume lookback) > 0 AND volume >= SMA(volume, volume lookback) × volume multiplier
Calculation: Upper-stretch deceleration test = Regression slope < Regression slope[deceleration lookback bars ago] AND Regression slope > 0
Calculation: Lower-stretch deceleration test = Regression slope > Regression slope[deceleration lookback bars ago] AND Regression slope < 0
Calculation: Hard-gated upper stretch = close > upper ATR envelope AND every enabled hard regime, FVG, volume, and upper-stretch deceleration filter passes; a disabled use filter passes automatically
Calculation: Hard-gated lower stretch = close < lower ATR envelope AND every enabled hard regime, FVG, volume, and lower-stretch deceleration filter passes; a disabled use filter passes automatically
Long: Regression slope > 0 AND low <= Regression trend line AND close > Regression trend line
Short: Regression slope < 0 AND high >= Regression trend line AND close < Regression trend line
Long: Regression slope > upper slope threshold
Short: Regression slope < lower slope threshold
Exit: long, close > upper ATR envelope AND ((Hard-gated upper stretch AND (first-occurrence-only is off OR neither hard-gated stretch event was true on the preceding bar)) OR (Hard-gated upper stretch is false AND neither pullback-entry condition is true))
Exit: short, close < lower ATR envelope AND ((Hard-gated lower stretch AND (first-occurrence-only is off OR neither hard-gated stretch event was true on the preceding bar)) OR (Hard-gated lower stretch is false AND neither pullback-entry condition is true))