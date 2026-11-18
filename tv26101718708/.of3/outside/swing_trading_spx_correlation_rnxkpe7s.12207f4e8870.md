Calculation: trend state = 1 if the VWMA(P1) of the S&P 500 percentage of stocks above their 200-day moving average on T1 is higher than each of its previous P2 values; -1 if it is lower than each of its previous P2 values; otherwise its prior value, initially 0
Long: trend state = 1 AND prior trend state = -1
Exit: long, trend state = -1 AND prior trend state = 1