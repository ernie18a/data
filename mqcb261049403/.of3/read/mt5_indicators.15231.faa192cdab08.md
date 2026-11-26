Calculation: relative-strength line = RSX(applied price, price-smoothing method/lookback/phase, signal-smoothing method/lookback/phase)
Calculation: momentum scale = RMS(one-bar change in relative-strength line, lookback)
Long: relative-strength line > relative-strength line[1]
Short: relative-strength line < relative-strength line[1]
Long: round(one-bar change in relative-strength line, instrument digits + 2) > round(multiplier × momentum scale, instrument digits + 2)
Short: round(one-bar change in relative-strength line, instrument digits + 2) < -round(multiplier × momentum scale, instrument digits + 2)
Long: on chart bars using the still-forming T1 bar's relative-strength line, calculated on T1 with the price and signal smoothers sharing one lookback and phase, relative-strength line > relative-strength line[1]
Short: on chart bars using the still-forming T1 bar's relative-strength line, calculated on T1 with the price and signal smoothers sharing one lookback and phase, relative-strength line < relative-strength line[1]
Long: on chart bars using the still-forming T1 bar's relative-strength line and momentum scale, calculated on T1 with the price and signal smoothers sharing one lookback and phase, round(one-bar change in relative-strength line, instrument digits + 2) > round(multiplier × momentum scale, instrument digits + 2)
Short: on chart bars using the still-forming T1 bar's relative-strength line and momentum scale, calculated on T1 with the price and signal smoothers sharing one lookback and phase, round(one-bar change in relative-strength line, instrument digits + 2) < -round(multiplier × momentum scale, instrument digits + 2)