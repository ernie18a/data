Calculation: Pre-market high/low = maximum high / minimum low during the configured pre-market window; use the completed window for that day.
Calculation: Opening-range high/low = maximum high / minimum low during the configured opening-range window; use the completed window for that day.
Calculation: ATR = average true range over the configured lookback on the configured timeframe, using the value returned for the current bar.
Calculation: ATR stop/target = entry price minus/plus the configured ATR fraction for a long position, and plus/minus that fraction for a short position.
Calculation: Trend MA = configured moving average of the configured price source over its lookback.
Calculation: Trailing stop = highest price since entry minus the configured trail distance for a long position; lowest price since entry plus that distance for a short position.
Long: Close crosses above the selected breakout-range high AND current time is within the configured entry session AND trades opened today are below the configured daily maximum AND long entries are enabled.
Short: Close crosses below the selected breakout-range low AND current time is within the configured entry session AND trades opened today are below the configured daily maximum AND short entries are enabled.
Exit: Long, current time is at or after the configured session close.
Exit: Short, current time is at or after the configured session close.
Exit: Long, low <= ATR stop OR high >= ATR target.
Exit: Short, high >= ATR stop OR low <= ATR target.
Exit: Long, low <= ATR stop OR high >= first partial ATR target OR high >= second partial ATR target OR high >= full ATR target.
Exit: Short, high >= ATR stop OR low <= first partial ATR target OR low <= second partial ATR target OR low <= full ATR target.
Exit: Long, low <= trailing stop.
Exit: Short, high >= trailing stop.
Exit: Long, close crosses below Trend MA OR low <= ATR stop.
Exit: Short, close crosses above Trend MA OR high >= ATR stop.
Exit: Long, low <= entry price minus configured scalp stop distance OR high >= entry price plus configured scalp target distance.
Exit: Short, high >= entry price plus configured scalp stop distance OR low <= entry price minus configured scalp target distance.
Exit: Long, low <= pre-market high minus configured fraction of the pre-market range OR high >= ATR target.
Exit: Short, high >= pre-market low plus configured fraction of the pre-market range OR low <= ATR target.