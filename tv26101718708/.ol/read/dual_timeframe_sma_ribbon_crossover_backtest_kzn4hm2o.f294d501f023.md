Calculation: SMA = moving average of (high + low + close) / 3 over the configured lookback
Calculation: Displaced SMA = the same SMA shifted by the configured offset
Calculation: Higher-timeframe SMAs = SMA and Displaced SMA calculated from higher-timeframe bars, using the last completed higher-timeframe bar
Calculation: Current higher-timeframe range = highest high and lowest low so far in the current, still-forming higher-timeframe period
Calculation: Long stop distance = absolute value of (lowest low over the configured lookback of completed chart bars minus current close minus the configured price adjustment), scaled to strategy ticks
Calculation: Short stop distance = absolute value of (highest high over the configured lookback of completed chart bars minus current close plus the configured price adjustment), scaled to strategy ticks
Long: SMA crosses Displaced SMA in either direction AND current open is below both SMAs AND current close is above both SMAs AND current higher-timeframe range low and high are both above both higher-timeframe SMAs AND (time limiter is disabled OR current bar time is after the configured start time)
Short: SMA crosses Displaced SMA in either direction AND current open is above both SMAs AND current close is below both SMAs AND current higher-timeframe range low and high are both below both higher-timeframe SMAs AND (time limiter is disabled OR current bar time is after the configured start time)
Exit: Long, low <= entry price minus the current long stop distance OR high >= entry price plus twice the current long stop distance
Exit: Short, high >= entry price plus the current short stop distance OR low <= entry price minus twice the current short stop distance