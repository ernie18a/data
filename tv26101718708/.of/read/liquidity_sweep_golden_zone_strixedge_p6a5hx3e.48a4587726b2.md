Calculation: Active swing high and low = the most recently confirmed pivot high and pivot low, using the same number of bars on each side. On each bar, first replace each level with any newly confirmed pivot; then, if low < active swing low AND close > active swing low, replace the active swing low with low; if high > active swing high AND close < active swing high, replace the active swing high with high. Sweep comparisons use the levels before these sweep replacements. Pivot ties follow TradingView pivot rules.
Calculation: Golden zone lower and upper boundaries = lowest low over the lookback plus the range from that low to the highest high over the same lookback multiplied by the lower and upper Fibonacci ratios, respectively; the current bar is included.
Calculation: Recent sweep direction = the direction of the latest sweep within the sweep-memory lookback, including the current bar; bullish takes precedence if both sweeps occur on the same bar; otherwise the direction is neutral.
Calculation: Swing midpoint = (active swing high + active swing low) / 2, using levels after the current bar's sweep replacements.
Calculation: Timeframe readings = calculate recent sweep direction, golden zone boundaries, swing midpoint, short- and long-period close EMAs, and close RSI independently on each of four progressively higher timeframes. Relative to the chart timeframe, a higher timeframe uses its last completed bar, a lower timeframe uses its last completed intrabar within the chart bar, and an equal timeframe uses the chart bar.
Calculation: Bullish count = across the four timeframe readings, count each occurrence of recent sweep direction = bullish, close >= golden zone lower boundary, close > swing midpoint, and short-period EMA > long-period EMA. Bearish count = similarly count recent sweep direction = bearish, close < golden zone lower boundary, close < swing midpoint, and short-period EMA < long-period EMA.
Long: low < active swing low AND close > active swing low, before the current bar's sweep replacement.
Short: high > active swing high AND close < active swing high, before the current bar's sweep replacement.
Long: low < active swing low AND close > active swing low, before the current bar's sweep replacement, AND close >= golden zone lower boundary AND close <= golden zone upper boundary.
Short: high > active swing high AND close < active swing high, before the current bar's sweep replacement, AND close >= golden zone lower boundary AND close <= golden zone upper boundary.
Long: On any timeframe reading, recent sweep direction = bullish.
Short: On any timeframe reading, recent sweep direction = bearish.
Long: On any timeframe reading, close > golden zone upper boundary.
Short: On any timeframe reading, close < golden zone lower boundary.
Long: On any timeframe reading, close > swing midpoint.
Short: On any timeframe reading, close < swing midpoint.
Long: On any timeframe reading, short-period EMA > long-period EMA.
Short: On any timeframe reading, short-period EMA < long-period EMA.
Long: On any timeframe reading, RSI >= the momentum midpoint AND RSI <= the upper RSI threshold.
Short: On any timeframe reading, RSI >= the lower RSI threshold AND RSI < the momentum midpoint.
Long: On any timeframe reading, at least three of RSI > the momentum midpoint, close >= golden zone lower boundary, close > swing midpoint, and short-period EMA > long-period EMA are true.
Short: On any timeframe reading, at least three of RSI < the momentum midpoint, close < golden zone lower boundary, close < swing midpoint, and short-period EMA < long-period EMA are true AND fewer than three of the corresponding bullish conditions are true.
Long: bullish count - bearish count >= the confluence threshold.
Short: bullish count - bearish count <= negative the confluence threshold.