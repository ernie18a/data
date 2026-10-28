Calculation: PI energy = EMA-smoothed 0–100 normalization of π × ATR² × signed square root of OBV rate of change; normalize against its rolling minimum and maximum, using 50 when they are equal
Calculation: PI ATR = ATR × max(minimum PI power, PI energy / 50)
Calculation: Compression = PI ATR < its simple moving average × compression ratio
Calculation: Center = EMA of close
Calculation: Upper and lower bands = Center ± PI ATR × band multiplier
Long: Position side is not long AND prior bar was in compression AND close > upper band AND close > center
Short: Position side is not short AND prior bar was in compression AND close < lower band AND close < center
Exit: long, not in compression AND close < upper band AND close > lower band
Exit: short, not in compression AND close < upper band AND close > lower band