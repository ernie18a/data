Calculation: Premarket high = highest high during that day's premarket session
Calculation: Premarket low = lowest low during that day's premarket session
Calculation: Bollinger width % = 100 × (upper band − lower band) / basis, with bands one standard deviation above and below the moving average
Calculation: Opening-window long block = true after any bar in the opening window has high > premarket high and close < premarket high; reset outside the window
Calculation: Opening-window short block = true after any bar in the opening window has low < premarket low and close > premarket low; reset outside the window
Calculation: Long stop = signal-bar close minus either ATR × stop multiplier or signal-bar close × stop percentage
Calculation: Short stop = signal-bar close plus either ATR × stop multiplier or signal-bar close × stop percentage
Calculation: Long target = signal-bar close + (signal-bar close − long stop) × risk/reward ratio
Calculation: Short target = signal-bar close − (short stop − signal-bar close) × risk/reward ratio
Long: during regular session AND close > premarket high AND (anti-chop filter disabled OR (ADX >= minimum ADX AND Bollinger width % > minimum width)) AND opening-window long block is false AND outside cooldown
Short: during regular session AND close < premarket low AND (anti-chop filter disabled OR (ADX >= minimum ADX AND Bollinger width % > minimum width)) AND opening-window short block is false AND outside cooldown
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target