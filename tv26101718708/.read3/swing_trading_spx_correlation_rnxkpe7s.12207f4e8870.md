Calculation: Trend state = 1 when VWMA(T1 close from the still-forming T1 bar, VWMA lookback), evaluated on chart bars, is rising over the direction lookback; -1 when it is falling over the direction lookback; otherwise its previous value, initially 0
Long: Trend state > 0
Long: Trend state > 0 AND Trend state[1] < 0
Short: Trend state < 0
Short: Trend state < 0 AND Trend state[1] > 0
Calculation: trend state = 1 if the VWMA(P1) of the S&P 500 percentage of stocks above their 200-day moving average on T1 is higher than each of its previous P2 values; -1 if it is lower than each of its previous P2 values; otherwise its prior value, initially 0
Long: trend state = 1 AND prior trend state = -1
Exit: long, trend state = -1 AND prior trend state = 1