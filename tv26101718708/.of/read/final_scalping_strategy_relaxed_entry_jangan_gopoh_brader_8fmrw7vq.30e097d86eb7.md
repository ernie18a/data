Calculation: ATR stop distance = ATR × stop multiplier
Calculation: Long stop price = signal-bar low − ATR stop distance
Calculation: Long target price = signal-bar close + (signal-bar close − long stop price) × reward-to-risk ratio
Calculation: Short stop price = signal-bar high + ATR stop distance
Calculation: Short target price = signal-bar close − (short stop price − signal-bar close) × reward-to-risk ratio
Long: close crosses above the chart-timeframe EMA AND close > the 50-period EMA calculated from the higher timeframe's last completed bar AND within the London or New York session AND no open position
Short: close crosses below the chart-timeframe EMA AND close < the 50-period EMA calculated from the higher timeframe's last completed bar AND within the London or New York session AND no open position
Exit: Long, low ≤ long stop price OR high ≥ long target price
Exit: Short, high ≥ short stop price OR low ≤ short target price