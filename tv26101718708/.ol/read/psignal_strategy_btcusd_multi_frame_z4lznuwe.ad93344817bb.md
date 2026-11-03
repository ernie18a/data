Calculation: P-Signal(L) = erf(SMA(change(OHLC4), L) / (stdev(change(OHLC4), L) × sqrt(2))); if stdev = 0, use erf(1)
Calculation: Daily smoothed P-Signal = SMA(P-Signal, L_D), using chart-timeframe bars
Calculation: Weekly smoothed P-Signal = SMA of the weekly P-Signal series over chart-timeframe bars; calculate P-Signal from weekly bars, including the still-forming weekly bar
Calculation: Monthly smoothed P-Signal = SMA of the monthly P-Signal series over chart-timeframe bars; calculate P-Signal from monthly bars, including the still-forming monthly bar
Long: Daily smoothed P-Signal < 0 AND greater than its prior value AND the daily entry valve is open
Long: Weekly smoothed P-Signal < 0 AND greater than its prior value AND the weekly entry valve is open
Long: Monthly smoothed P-Signal < 0 AND greater than its prior value AND the monthly entry valve is open
Exit: long, Daily smoothed P-Signal > 0 AND less than its prior value
Exit: long, Weekly smoothed P-Signal > 0 AND less than its prior value
Exit: long, Monthly smoothed P-Signal > 0 AND less than its prior value