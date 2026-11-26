Long: current chart-bar close > high of the last completed T1 bar AND no entry has been placed in the current T1 bar
Short: current chart-bar close < low of the last completed T1 bar AND no entry has been placed in the current T1 bar
Calculation: long stop = entry price − stop-loss distance; after the first current chart-bar close > entry price + stop-loss distance, set it to that close − stop-loss distance
Calculation: short stop = entry price + stop-loss distance; after the first current chart-bar close < entry price − stop-loss distance, set it to that close + stop-loss distance
Exit: long, current chart-bar close ≤ long stop OR current chart-bar close ≥ entry price + take-profit distance
Exit: short, current chart-bar close ≥ short stop OR current chart-bar close ≤ entry price − take-profit distance