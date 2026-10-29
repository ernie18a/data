Calculation: Dealing-range equilibrium = midpoint of the current weekly high and low on chart timeframes of 1H or higher; otherwise midpoint of the current daily high and low. Track the forming period using chart-timeframe bars.
Calculation: Confirmed swing high/low = chart-timeframe pivot high/low, confirmed after the configured number of bars to its right.
Calculation: Bullish/bearish fair value gap = three-bar gap where the current low is above the high two bars earlier / current high is below the low two bars earlier; the middle bar must close in the gap direction with body size meeting the configured ATR displacement floor, and the gap height must meet its configured ATR floor.
Calculation: Bullish/bearish suspension block = three consecutive up/down bars whose later bars open above/below the preceding close, with the total span meeting the configured ATR floor.
Calculation: Bullish/bearish order block = the body of the group of up to four consecutive down/up bars in the pullback from the latest confirmed swing high/low, anchored at the lowest down-bar close/highest up-bar close (ties use the larger body); the group bars must have similar body sizes. It qualifies when a same-direction displacement bar closes beyond the group’s full high/low and a same-direction fair value gap forms within the configured grace window. Apply any enabled block size, rally-distance, and context-grade filters.
Calculation: Failed-block breaker = a qualified order block whose full candle range extends from its group’s lowest low to highest high and whose polarity reverses when a chart-timeframe close passes through the full range. A bearish/bullish breaker is the configured breaker candle group at a confirmed swing low/high after price runs the prior swing high/low and then closes below/above that swing.
Long: close < Midnight Open AND close < Dealing-range equilibrium
Long: bullish fair value gap forms OR bullish suspension block forms
Long: close > latest confirmed swing high
Long: bullish order block qualifies OR bullish breaker forms
Short: close > Midnight Open AND close > Dealing-range equilibrium
Short: bearish fair value gap forms OR bearish suspension block forms
Short: close < latest confirmed swing low
Short: bearish order block qualifies OR bearish breaker forms