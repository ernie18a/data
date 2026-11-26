Calculation: Rolling VWAP dispersion = sqrt(mean((hlc3 - VWAP(hlc3, trailing calendar-day lookback))^2) over the trailing calendar-day lookback)
Calculation: Calendar-year VWAP dispersion = sqrt(sum((hlc3 - calendar-year-to-date VWAP at each bar)^2) / number of bars since calendar-year start)
Calculation: Institutional reference levels = VWAP(hlc3, trailing calendar-day lookback), that VWAP plus or minus rolling VWAP dispersion, calendar-year-to-date VWAP, that VWAP plus or minus calendar-year VWAP dispersion, SMA(close, shorter lookback), SMA(close, longer lookback)
Long: there is an institutional reference level L such that L < close AND (L is a VWAP or a VWAP plus or minus its dispersion OR at least two institutional reference levels are within ATR(lookback) * confluence multiplier of L)
Short: there is an institutional reference level L such that L >= close AND (L is a VWAP or a VWAP plus or minus its dispersion OR at least two institutional reference levels are within ATR(lookback) * confluence multiplier of L)
Long: PivotLow(low, pivot strength, pivot strength) is not na
Short: PivotHigh(high, pivot strength, pivot strength) is not na
Long: lowest(low, major structure lookback) <= close
Short: highest(high, major structure lookback) >= close