Calculation: Opening-range high = highest high during the opening-range window
Calculation: Opening-range low = lowest low during the opening-range window
Long: Close crosses above opening-range high AND bar is after the opening-range window AND close > VWAP AND last completed higher-timeframe close > its EMA AND position is flat AND fewer than two trades have been entered today AND no long has been entered today
Short: Close crosses below opening-range low AND bar is after the opening-range window AND close < VWAP AND last completed higher-timeframe close < its EMA AND position is flat AND fewer than two trades have been entered today AND no short has been entered today
Exit: Long, low <= entry price - stop distance OR high >= entry price + target distance
Exit: Short, high >= entry price + stop distance OR low <= entry price - target distance