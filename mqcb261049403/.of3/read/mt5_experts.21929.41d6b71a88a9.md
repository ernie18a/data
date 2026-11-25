Calculation: SAR = Parabolic SAR(high, low, step, maximum) from T1, mapped to chart bars using the mapped T1 bar's values, including while it is forming
Calculation: +DI = ADX positive directional indicator(high, low, close, lookback) from T1, mapped to chart bars using the mapped T1 bar's values, including while it is forming
Calculation: -DI = ADX negative directional indicator(high, low, close, lookback) from T1, mapped to chart bars using the mapped T1 bar's values, including while it is forming
Long: close[n] > SAR AND +DI > -DI AND (hour(datetime[n]) is between the start-hour and end-hour parameters when the hour filter is enabled)
Short: close[n] <= SAR AND +DI <= -DI AND (hour(datetime[n]) is between the start-hour and end-hour parameters when the hour filter is enabled)
Exit: long, (close[n] <= SAR AND +DI > -DI) OR (close[n] > SAR AND +DI <= -DI)
Exit: short, (close[n] <= SAR AND +DI > -DI) OR (close[n] > SAR AND +DI <= -DI)