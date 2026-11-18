Long: EMA(close, parameter 1) > EMA(close, parameter 2), where parameter 1 is shorter than parameter 2
Short: EMA(close, parameter 1) < EMA(close, parameter 2), where parameter 1 is shorter than parameter 2
Calculation: Opening-range high = maximum(high, chart bars from the session-start parameter through the opening-range-duration parameter after session start)
Calculation: Opening-range low = minimum(low, chart bars from the session-start parameter through the opening-range-duration parameter after session start)
Long: after the opening range completes, high crosses above Opening-range high
Short: after the opening range completes, low crosses below Opening-range low