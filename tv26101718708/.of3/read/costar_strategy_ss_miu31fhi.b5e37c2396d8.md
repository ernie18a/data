Calculation: R = Linear regression of X on Y over P+1 chart bars, evaluated at current Y; X and Y are the still-forming T1 closes requested with lookahead on, and P is the chart-timeframe-selected regression lookback parameter from six separate parameters
Calculation: E = sqrt(sum((R[n] - X[n])^2, n=0..P) / (P - 2))
Long: X crosses above R - E
Short: X crosses below R + E
Exit: long, X crosses above R
Exit: short, X crosses below R