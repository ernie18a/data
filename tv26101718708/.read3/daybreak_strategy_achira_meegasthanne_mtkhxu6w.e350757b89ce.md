Calculation: Opening-range high = high of the first chart bar at the session-opening time, reset each session
Calculation: Opening-range low = low of the first chart bar at the session-opening time, reset each session
Long: Opening-range high > opening-range low AND chart-bar close > chart-bar open
Short: NOT (opening-range high > opening-range low AND chart-bar close > chart-bar open)
Long: On T1 chart bars, once per session after capturing the opening bar, enter when high >= opening-range high + ATR(lookback, T1 bars at order placement) × sensitivity
Short: On T1 chart bars, once per session after capturing the opening bar, enter when low <= opening-range low − ATR(lookback, T1 bars at order placement) × sensitivity
Exit: Long, high >= entry price + take-profit parameter (ticks) OR low <= entry price − stop-loss parameter (ticks)
Exit: Short, low <= entry price − take-profit parameter (ticks) OR high >= entry price + stop-loss parameter (ticks)