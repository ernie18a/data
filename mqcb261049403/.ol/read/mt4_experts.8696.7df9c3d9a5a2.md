Calculation: Upper channel = highest high of the previous N completed chart-timeframe bars, excluding the current bar
Calculation: Lower channel = lowest low of the previous N completed chart-timeframe bars, excluding the current bar
Calculation: Stop distance = channel width × stop-loss percentage
Short: current price >= upper channel AND within the configured operating window AND no orders remain open after closing long positions
Long: current price <= lower channel AND within the configured operating window AND no orders remain open after closing short positions
Exit: Long, current price >= upper channel OR current price <= entry price - stop distance
Exit: Short, current price <= lower channel OR current price >= entry price + stop distance