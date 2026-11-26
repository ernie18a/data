Calculation: Long stop = low of long entry bar - ATR(lookback) on chart bars at entry * ATR stop multiplier
Calculation: Short stop = high of short entry bar + ATR(lookback) on chart bars at entry * ATR stop multiplier
Calculation: Long target = entry price + (entry price - long stop) * reward/risk ratio
Calculation: Short target = entry price - (short stop - entry price) * reward/risk ratio
Long: on chart bars, low < low of last completed T1 bar AND close > low of last completed T1 bar AND no earlier trade today
Short: on chart bars, high > high of last completed T1 bar AND close < high of last completed T1 bar AND no earlier trade today
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target