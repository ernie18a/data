Calculation: Rolling VWAP = sum(hlc3 × volume) / sum(volume) over a rolling time window, retaining a minimum recent bar count
Calculation: Rolling standard deviation = sqrt(max(sum(hlc3² × volume) / sum(volume) − Rolling VWAP², 0)) over the same window
Calculation: Upper and lower standard deviation bands = Rolling VWAP ± Rolling standard deviation × band multiplier
Long: On a confirmed bar, close crosses above the lower standard deviation band
Short: On a confirmed bar, close crosses below the upper standard deviation band
Exit: Long, on a confirmed bar, high crosses above Rolling VWAP
Exit: Short, on a confirmed bar, low crosses below Rolling VWAP