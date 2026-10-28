Calculation: Trend state = +1 when the VWMA of daily closes is higher than every value in its lookback; −1 when it is lower than every value in its lookback; otherwise its prior value. The daily close may be from the bar still forming.
Long: trend state = +1 AND prior trend state = −1
Short: trend state = −1 AND prior trend state = +1
Exit: long, trend state = −1 AND prior trend state = +1