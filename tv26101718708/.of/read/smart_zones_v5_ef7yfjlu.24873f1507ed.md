Calculation: Prior high and prior low = highest high and lowest low over a lookback ending on the preceding chart bar.
Calculation: Bullish sweep = preceding chart-bar low <= prior low AND current close > prior low. Bearish sweep = preceding chart-bar high >= prior high AND current close < prior high.
Calculation: Bullish engulfing = absolute candle body >= ATR times a size multiplier AND close > open AND (close - low) / (high - low) >= a close-location threshold AND close > preceding open AND open < preceding close AND volume >= its moving average times a volume multiplier. Bearish engulfing = absolute candle body >= ATR times the same size multiplier AND close < open AND (close - low) / (high - low) <= the complementary close-location threshold AND close < preceding open AND open > preceding close AND volume >= its moving average times the same volume multiplier. When high equals low, use the midpoint as the close location.
Calculation: Range = when the highest high minus the lowest low over a lookback first becomes <= ATR times a range-height multiplier, start a range with those high and low values. While that condition remains true, extend the range high and low with the current bar's high and low. Retain the range after the condition becomes false; end it on the first range break in either direction.
Calculation: Long break-of-structure level = on each bullish sweep, replace the pending level with the highest high over a lookback ending on the preceding chart bar. Clear it after close exceeds it or the long setup is invalidated. Short break-of-structure level = on each bearish sweep, replace the pending level with the lowest low over the same lookback ending on the preceding chart bar. Clear it after close falls below it or the short setup is invalidated.
Calculation: Active setup stop = on a bullish sweep, store prior low minus ATR times a stop multiplier and activate the long setup; on a bearish sweep, store prior high plus ATR times the same multiplier and activate the short setup. Activating either setup deactivates the other. If both sweeps occur on the same bar, the short setup takes precedence. Clear an active setup when its stop is invalidated.
Long: Bullish sweep.
Short: Bearish sweep.
Long: Bullish engulfing.
Short: Bearish engulfing.
Long: Chart-bar low > high two chart bars earlier AND the difference >= close times a gap-size fraction.
Short: Chart-bar high < low two chart bars earlier AND the difference >= close times the same gap-size fraction.
Long: Last completed higher-timeframe bar's low > preceding higher-timeframe bar's high AND the difference >= chart close times a higher-timeframe gap-size fraction. Apply independently to each of two higher timeframes, one longer than the other.
Short: Last completed higher-timeframe bar's high < preceding higher-timeframe bar's low AND the difference >= chart close times the same higher-timeframe gap-size fraction. Apply independently to each of the two higher timeframes.
Long: Pending long break-of-structure level exists AND close > that level.
Short: Pending short break-of-structure level exists AND close < that level.
Long: Range is active AND close > range high AND open < range high AND absolute candle body >= ATR times a breakout-body multiplier.
Short: Range is active AND close < range low AND open > range low AND absolute candle body >= ATR times the same breakout-body multiplier.
Exit: long, long setup is active AND close < its stored stop.
Exit: short, short setup is active AND close > its stored stop.