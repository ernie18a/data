Calculation: Prior high and prior low = highest high and lowest low over a lookback ending at the previous chart bar.
Calculation: Up sweep = previous chart bar's low <= prior low AND close > prior low. Down sweep = previous chart bar's high >= prior high AND close < prior high.
Calculation: Volume spike = volume >= a multiple of the chart-timeframe simple moving average of volume, including the current bar.
Calculation: Bullish engulf = absolute candle body >= a multiple of ATR AND close > open AND (close - low) / (high - low) >= an upper threshold AND close > previous open AND open < previous close AND volume spike; use 0.5 for the close-location ratio when high equals low. Bearish engulf = absolute candle body >= the same multiple of ATR AND close < open AND the close-location ratio <= a lower threshold AND close < previous open AND open > previous close AND volume spike.
Calculation: Bullish chart gap = low > high two chart bars ago AND their difference >= a fraction of close. Bearish chart gap = high < low two chart bars ago AND their difference >= the same fraction of close.
Calculation: Higher-timeframe bullish gap = the last completed higher-timeframe bar's low > the preceding higher-timeframe bar's high AND their difference >= a fraction of the current chart close. Higher-timeframe bearish gap = the last completed higher-timeframe bar's high < the preceding higher-timeframe bar's low AND their difference >= the same fraction of the current chart close. Calculate these on two higher timeframes, one longer than the other.
Calculation: Range = when the highest high minus the lowest low over a chart-bar lookback first becomes <= a multiple of ATR, store those extremes and activate the range. While that condition remains true, extend the stored extremes with each bar's high and low before checking for a break. Deactivate the range after either break, even if volume is not elevated.
Calculation: Long break = an active range AND close > stored range high AND open < stored range high AND absolute candle body >= a multiple of ATR. Short break = an active range AND close < stored range low AND open > stored range low AND absolute candle body >= the same multiple of ATR.
Calculation: Long structure-break level = on each up sweep, store the highest high over a separate chart-bar lookback ending on the previous bar and activate a pending long confirmation; replace the level on another up sweep. Short structure-break level = on each down sweep, store the lowest low over the same lookback ending on the previous bar and activate a pending short confirmation; replace the level on another down sweep. Deactivate the relevant pending confirmation after its confirmation or its setup invalidation.
Calculation: Long setup stop = prior low minus a multiple of ATR on the latest up sweep. Short setup stop = prior high plus the same multiple of ATR on the latest down sweep. An up sweep activates the long setup and deactivates the short setup; a down sweep activates the short setup and deactivates the long setup, with the down sweep processed last if both occur. A setup is invalidated when its active stop is crossed by the close; then deactivate that setup.
Long: Up sweep.
Short: Down sweep.
Long: Bullish engulf.
Short: Bearish engulf.
Long: Bullish chart gap.
Short: Bearish chart gap.
Long: Higher-timeframe bullish gap.
Short: Higher-timeframe bearish gap.
Long: Pending long confirmation AND close > long structure-break level.
Short: Pending short confirmation AND close < short structure-break level.
Long: Long break.
Short: Short break.
Exit: long, long setup is active AND close < long setup stop.
Exit: short, short setup is active AND close > short setup stop.