Calculation: Harmonic gravity center = sum(volume) / sum(volume / close) over the lookback window
Calculation: Upper deviation band = harmonic gravity center + multiplier × square root of the mean squared difference between each close in the lookback window and the current harmonic gravity center
Calculation: Lower deviation band = harmonic gravity center − multiplier × square root of the mean squared difference between each close in the lookback window and the current harmonic gravity center
Long: close < lower deviation band
Short: close > upper deviation band
Exit: long, close >= harmonic gravity center
Exit: short, close <= harmonic gravity center