Calculation: Applied price = select by parameter: 1 = open; 2 = high; 3 = low; 4 = (high + low)/2; 5 = (high + low + close)/3; 6 = (high + low + 2 × close)/4; 7 = close; 8 = (open + close)/2; 9 = (open + high + low + close)/4; 10 = high if close > open, low if close < open, otherwise close; 11 = (high + close)/2 if close > open, (low + close)/2 if close < open, otherwise close; 12 = (X − low + X − high)/2, where X = (high + low + close + low)/2 if close < open, (high + low + close + high)/2 if close > open, otherwise (high + low + 2 × close)/2.
Calculation: VWMA = sum of applied price × volume over the lookback divided by sum of volume over the same lookback.
Calculation: Rounded change = current VWMA minus previous VWMA, rounded to the configured price precision plus two decimal places.
Calculation: Filter 1 and filter 2 = population standard deviation of VWMA changes over the filter lookback, multiplied by the respective independently configurable first and second coefficients and rounded to the configured price precision plus two decimal places.
Long: Current VWMA > previous VWMA.
Short: Current VWMA < previous VWMA.
Long: Rounded change > filter 1 AND rounded change <= filter 2.
Long: Rounded change > filter 2.
Short: Rounded change < −filter 1 AND rounded change >= −filter 2.
Short: Rounded change < −filter 2.