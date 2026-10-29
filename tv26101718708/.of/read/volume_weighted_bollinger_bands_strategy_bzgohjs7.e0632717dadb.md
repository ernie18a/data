Calculation: Average weighting = mean of four EMAs of close with progressively longer lookbacks and VWAP
Calculation: Basis = simple moving average of average weighting
Calculation: Band deviation = standard deviation of average weighting over the basis lookback, multiplied by a multiplier
Calculation: Upper band = basis + band deviation
Calculation: Lower band = basis − band deviation
Long: close > upper band AND previous bar close > upper band
Short: close < lower band AND previous bar close < lower band
Exit: long, close < lower band AND previous bar close < lower band
Exit: short, close > upper band AND previous bar close > upper band