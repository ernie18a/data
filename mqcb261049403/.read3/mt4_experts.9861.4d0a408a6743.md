Long: on chart bars, close > open(T1, bar still forming) AND open(T1, bar still forming) - low(T1, bar still forming) > range-threshold parameter in points AND hour(datetime) < long-entry-hour parameter
Short: on chart bars, close < open(T1, bar still forming) AND high(T1, bar still forming) - open(T1, bar still forming) > range-threshold parameter in points AND hour(datetime) < short-entry-hour parameter
Exit: long, hour(datetime) > close-hour parameter - offset parameter
Exit: short, hour(datetime) > close-hour parameter - offset parameter