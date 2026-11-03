Calculation: Upper threshold = high of the last completed bar on a timeframe higher than the chart timeframe + configured point offset
Calculation: Lower threshold = low of the last completed bar on a timeframe higher than the chart timeframe − configured point offset
Long: previous chart bar open > Lower threshold AND current chart bar open < Lower threshold
Short: previous chart bar open < Upper threshold AND current chart bar open > Upper threshold
Exit: long, bar low ≤ entry price − configured fixed distance OR bar high ≥ entry price + configured fixed distance
Exit: short, bar high ≥ entry price + configured fixed distance OR bar low ≤ entry price − configured fixed distance