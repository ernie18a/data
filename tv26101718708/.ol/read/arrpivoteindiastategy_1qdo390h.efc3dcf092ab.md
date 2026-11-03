Calculation: Pivot point = (previous completed daily high + previous completed daily low + previous completed daily close) / 3, using a higher timeframe
Calculation: First resistance = 2 × pivot point − previous completed daily low
Calculation: First support = 2 × pivot point − previous completed daily high
Calculation: Selected reference level = selected from previous completed daily high, previous completed daily low, pivot point, first resistance, and first support
Calculation: Stop distance in ticks = previous completed daily close × max-loss fraction, using a higher timeframe
Long: current bar open < selected reference level AND current bar close > selected reference level AND current bar hour < (close-all hour − 2) AND position is flat or short
Short: current bar open > selected reference level AND current bar close < selected reference level AND current bar hour < (close-all hour − 2) AND position is flat or short
Exit: long, adverse price movement from entry reaches the stop distance in ticks OR current bar hour = close-all hour
Exit: short, adverse price movement from entry reaches the stop distance in ticks OR current bar hour = close-all hour