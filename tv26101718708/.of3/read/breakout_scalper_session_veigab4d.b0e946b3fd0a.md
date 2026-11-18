Calculation: Fast lower band = max(current day's running low, lowest(low, fast lookback))
Calculation: Fast upper band = min(current day's running high, highest(high, fast lookback))
Calculation: Fast midpoint = (Fast lower band + Fast upper band) / 2
Calculation: Cloud percentage = (Fast midpoint - (current day's running high + current day's running low) / 2) / ATR(slow lookback)
Long: configured session is open AND EMA(close, instant lookback) > Fast midpoint AND Cloud percentage > cloud entry threshold AND high >= current day's running high
Short: configured session is open AND EMA(close, instant lookback) < Fast midpoint AND Cloud percentage < -cloud entry threshold AND low <= current day's running low
Exit: long, low <= Fast lower band OR configured session just ended OR Cloud percentage < cloud neutral threshold
Exit: short, high >= Fast upper band OR configured session just ended OR Cloud percentage > cloud neutral threshold