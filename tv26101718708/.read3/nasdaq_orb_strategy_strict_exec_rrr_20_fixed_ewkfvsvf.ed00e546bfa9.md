Calculation: Opening-range high = maximum high during the opening-range period
Calculation: Opening-range low = minimum low during the opening-range period
Calculation: Opening-range midpoint = (opening-range high + opening-range low) / 2
Long: close crosses above opening-range high AND RVOL(volume, lookback) >= minimum RVOL threshold
Short: close crosses below opening-range low AND RVOL(volume, lookback) >= minimum RVOL threshold
Exit: Long, low <= opening-range midpoint at entry OR high >= entry price + (entry price - opening-range midpoint at entry) * risk-reward ratio
Exit: Short, high >= opening-range midpoint at entry OR low <= entry price - (opening-range midpoint at entry - entry price) * risk-reward ratio
Exit: Long, hour(datetime, America/New_York) = 16 AND minute(datetime, America/New_York) = 0
Exit: Short, hour(datetime, America/New_York) = 16 AND minute(datetime, America/New_York) = 0