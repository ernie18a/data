Calculation: Breakout high = highest high over the configured lookback of chart-timeframe bars, including the bar still forming
Calculation: Breakout low = lowest low over the configured lookback of chart-timeframe bars, including the bar still forming
Long: Ask reaches the higher of Breakout high plus the configured offset and Ask plus the minimum stop distance, AND no long pending order or open position exists, AND the configured time filter is satisfied when enabled
Short: Bid reaches the lower of Breakout low minus the configured offset and Bid minus the minimum stop distance, AND no short pending order or open position exists, AND the configured time filter is satisfied when enabled
Exit: Long, low <= active stop loss OR high >= take-profit price
Exit: Short, high >= active stop loss OR low <= take-profit price