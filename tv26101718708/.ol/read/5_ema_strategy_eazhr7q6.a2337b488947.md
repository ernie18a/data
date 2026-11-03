Calculation: EMA = exponential moving average of close
Calculation: Long stop price = lower of the entry bar low and the previous bar low
Calculation: Short stop price = higher of the entry bar high and the previous bar high
Calculation: Take-profit price = entry price + (entry price − stop price) × configured multiple
Long: current high > the high of the latest alert bar whose open, high, low, and close were all below EMA AND position is flat AND daily entry count < configured daily maximum AND long trading is enabled
Short: current low < the low of the latest alert bar whose open, high, low, and close were all above EMA AND position is flat AND daily entry count < configured daily maximum AND short trading is enabled
Exit: Long, current low ≤ long stop price OR current high ≥ take-profit price
Exit: Short, current high ≥ short stop price OR current low ≤ take-profit price