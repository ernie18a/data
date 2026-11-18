Calculation: spread = (high(first input series, T1, bar still forming) + low(first input series, T1, bar still forming)) / 2 - (high(second input series, T1, bar still forming) + low(second input series, T1, bar still forming)) / 2, sampled on chart bars
Long: spread < 0 AND year(datetime) > start-year parameter AND chart bar is confirmed
Exit: long, spread > exit-threshold parameter