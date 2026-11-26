Calculation: Pre-market high = maximum high during the pre-market session
Calculation: Pre-market low = minimum low during the pre-market session
Long: session.ismarket AND crossover(close, pre-market high)
Short: session.ismarket AND crossunder(close, pre-market low)
Long: crossover(close, VWAP(hlc3, volume, anchor period, volume window))
Short: crossunder(close, VWAP(hlc3, volume, anchor period, volume window))