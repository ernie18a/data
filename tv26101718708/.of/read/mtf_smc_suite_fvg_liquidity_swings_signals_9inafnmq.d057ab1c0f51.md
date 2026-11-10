Calculation: Bullish gap = low > high two bars earlier; its upper boundary is the current low and its lower boundary is the high two bars earlier.
Calculation: Bearish gap = high < low two bars earlier; its upper boundary is the low two bars earlier and its lower boundary is the current high.
Calculation: Active gap boundaries = the boundaries of the most recently detected bullish or bearish gap; either type of new gap replaces both boundaries. A new gap activates its own direction without deactivating the other direction. Deactivate each direction after its corresponding inverse-gap decision.
Calculation: Confirmed swing high or low = a pivot high or low confirmed after the same number of bars on each side, using a configurable swing lookback. Keep the latest confirmed high and low separately; replace each on a new pivot and clear it after the corresponding break-of-structure decision. Update pivots before evaluating breaks, and clear broken pivots before evaluating gap-and-swing signals.
Calculation: Bullish engulfing = previous close < previous open AND close > open AND close >= previous open AND open <= previous close.
Calculation: Bearish engulfing = previous close > previous open AND close < open AND close <= previous open AND open >= previous close.
Calculation: Body = absolute value of close minus open; range = high minus low; upper wick = high minus the greater of open and close; lower wick = the lesser of open and close minus low.
Calculation: Bullish hammer = lower wick >= body times a configurable multiple AND upper wick <= body times a configurable fraction AND close > open.
Calculation: Bearish shooting star = upper wick >= body times the same multiple AND lower wick <= body times the same fraction AND close < open.
Calculation: Bullish pin bar = lower wick >= range times a configurable fraction AND body <= range times a second configurable fraction.
Calculation: Bearish pin bar = upper wick >= range times the same wick fraction AND body <= range times the same body fraction.
Calculation: Multi-timeframe bullish count = count of configured timeframes where the shorter-period close EMA > the longer-period close EMA. Bearish count = count of configured timeframes where that comparison is false, including equality. For a higher timeframe use its last completed bar; for a lower timeframe use its last available completed bar within the chart bar; for the chart timeframe use the current chart bar.
Calculation: Multi-timeframe bullish or bearish gap confirmation = at least one corresponding gap on a configured shorter-timeframe subset of the timeframes used for the EMA count. Use the last completed bar for each higher timeframe, the last available completed bar within the chart bar for each lower timeframe, and the current bar for the chart timeframe.
Long: Bullish gap.
Short: Bearish gap.
Long: Bullish gap direction is active AND close < active gap upper boundary.
Short: Bearish gap direction is active AND close > active gap lower boundary.
Long: Close > latest confirmed swing high.
Short: Close < latest confirmed swing low.
Long: Bullish engulfing OR bullish hammer OR bullish pin bar.
Short: Bearish engulfing OR bearish shooting star OR bearish pin bar.
Long: Multi-timeframe bullish count >= configurable threshold AND multi-timeframe bullish gap confirmation AND (bullish engulfing OR bullish hammer OR bullish pin bar) AND a swing low is confirmed on the current bar.
Short: Multi-timeframe bearish count >= configurable threshold AND multi-timeframe bearish gap confirmation AND (bearish engulfing OR bearish shooting star OR bearish pin bar) AND a swing high is confirmed on the current bar.
Long: Bullish gap AND a swing low is confirmed on the current bar AND close > latest retained confirmed swing low.
Short: Bearish gap AND a swing high is confirmed on the current bar AND close < latest retained confirmed swing high.
Long: Close > latest confirmed swing high AND bullish gap.
Short: Close < latest confirmed swing low AND bearish gap.