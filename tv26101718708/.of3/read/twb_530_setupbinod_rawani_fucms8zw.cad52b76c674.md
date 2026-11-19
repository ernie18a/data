Calculation: setup high = high of the setup-time T1 bar, mapped onto chart bars from the T1 bar while it is forming in real time and at completion historically
Calculation: setup low = low of the setup-time T1 bar, mapped onto chart bars from the T1 bar while it is forming in real time and at completion historically
Calculation: setup range = setup high - setup low
Calculation: upper retracement level = setup high - (setup range * upper retracement parameter)
Calculation: lower retracement level = setup high - (setup range * lower retracement parameter)
Calculation: entry price = upper retracement level for long positions; lower retracement level for short positions
Calculation: stop price = lower retracement level for long positions; upper retracement level for short positions
Calculation: target price = entry price + (absolute value of entry price - stop price * target multiple) for long positions; entry price - (absolute value of stop price - entry price * target multiple) for short positions
Long: setup captured AND no breakout has occurred since the latest day reset AND no trade has been taken since the latest day reset AND close > setup high
Short: setup captured AND no breakout has occurred since the latest day reset AND no trade has been taken since the latest day reset AND close < setup low
Long: long breakout active AND no trade has been taken since the latest day reset AND low <= upper retracement level AND close > open
Short: short breakout active AND no trade has been taken since the latest day reset AND high >= lower retracement level AND close < open
Exit: long, high >= target price
Exit: long, high < target price AND low <= stop price
Exit: short, low <= target price
Exit: short, low > target price AND high >= stop price