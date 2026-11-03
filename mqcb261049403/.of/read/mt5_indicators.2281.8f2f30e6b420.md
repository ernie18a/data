Calculation: Stop distance = a fixed price distance in price-deviation mode, or a multiplier times the EMA of ATR in ATR mode.
Calculation: Pivot stop = initialize to the close immediately before the first eligible bar; thereafter, using the previous bar's pivot stop: if the current close equals it, retain it; otherwise, if both the previous and current closes are below it, take the minimum of it and current close plus stop distance; otherwise, if both closes are above it, take the maximum of it and current close minus stop distance; otherwise, if the current close is above it, use current close minus stop distance; otherwise use current close plus stop distance.
Calculation: Sampled trend = on the first chart bar of each higher-timeframe bar, evaluate the ATR-mode pivot stop and close of that higher-timeframe bar still forming; retain that comparison until the next higher-timeframe bar. If the selected timeframe equals the chart timeframe, evaluate each chart bar.
Long: Chart close > chart pivot stop.
Short: Chart close < chart pivot stop.
Long: Sampled trend close > sampled trend pivot stop.
Short: Sampled trend close < sampled trend pivot stop.