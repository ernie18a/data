Calculation: premium = last recorded value of (traded instrument close[1] - index close[1]) from the last completed T1 bar, recorded only where both T1 bar close times are equal; 0 before the first record
Calculation: structure short = true after close crosses under last PivotLow(low, swing length, swing length), false after close crosses over last PivotHigh(high, swing length, swing length), otherwise unchanged; false initially
Calculation: structure long = true after close crosses over last PivotHigh(high, swing length, swing length), false after close crosses under last PivotLow(low, swing length, swing length), otherwise unchanged; false initially
Calculation: CVD = cumulative sum of (volume if close >= open, else -volume)
Long: close > ceiling level + premium
Long: close > ceiling level + premium AND structure long
Long: close > ceiling level + premium AND structure long AND CVD > CVD[CVD lookback]
Short: close < zero gamma level + premium
Short: close < zero gamma level + premium AND structure short
Short: close < zero gamma level + premium AND structure short AND CVD < CVD[CVD lookback]
Short: close >= short zone bottom + premium AND close <= short zone top + premium
Long: close >= long zone bottom + premium AND close <= long zone top + premium
Exit: short, close >= short stop + premium
Exit: short, close < zero gamma level + premium AND close <= short target 1 + premium
Exit: short, close < zero gamma level + premium AND close <= short target 2 + premium
Exit: long, close > ceiling level + premium AND close >= long target 1 + premium
Exit: long, close > ceiling level + premium AND close >= long target 2 + premium
Exit: long, close <= long stop + premium