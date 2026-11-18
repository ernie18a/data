Calculation: True range = max(high − low, abs(high − previous close), abs(low − previous close))
Calculation: Range = true range or high − low, selected by a parameter
Calculation: Upper band = SMA(close, length) + SMA(range, length) × multiplier
Calculation: Lower band = SMA(close, length) − SMA(range, length) × multiplier
Calculation: Conversion midpoint = (lowest low + highest high) / 2 over a parameterized lookback
Calculation: Base midpoint = (lowest low + highest high) / 2 over a separately parameterized lookback
Long: close > upper band AND conversion midpoint > base midpoint
Short: close < lower band AND conversion midpoint < base midpoint
Exit: long, close < lower band AND conversion midpoint < base midpoint
Exit: short, close > upper band AND conversion midpoint > base midpoint