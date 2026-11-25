Calculation: paired SMMA difference = SMMA(median price of one signal series, lookback parameter, shift parameter, T1, current/forming bar sampled at each chart tick) − SMMA(median price of its paired signal series, same lookback parameter, same shift parameter, T1, current/forming bar sampled at each chart tick)
Calculation: aggregate SMMA difference = sum of paired SMMA differences across the four signal pairs
Long: aggregate SMMA difference > 0 AND the corresponding paired SMMA difference > 0 AND no open position in the traded series
Short: aggregate SMMA difference < 0 AND the corresponding paired SMMA difference < 0 AND no open position in the traded series
Calculation: profit distance = max(minimum-distance parameter in pips × point size × (10 if quote precision is 3 or 5 digits, otherwise 1), mean(high − low, lookback parameter, T2, last completed bars sampled at each chart tick))
Exit: long, bid > entry price + profit distance
Exit: short, ask < entry price − profit distance