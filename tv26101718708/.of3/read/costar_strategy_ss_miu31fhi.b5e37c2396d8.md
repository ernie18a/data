Calculation: R = Linear regression of X on Y over P+1 chart bars, evaluated at current Y; X and Y are the still-forming T1 closes requested with lookahead on, and P is the chart-timeframe-selected regression lookback parameter from six separate parameters
Calculation: E = sqrt(sum((R[n] - X[n])^2, n=0..P) / (P - 2))
Long: X crosses above R - E
Short: X crosses below R + E
Exit: long, X crosses above R
Exit: short, X crosses below R
Calculation: Pair regression value = paired-instrument close on T1 × covariance(traded-instrument close on T1, paired-instrument close on T1) / variance(paired-instrument close on T1) + average(traded-instrument close on T1) − average(paired-instrument close on T1) × covariance(traded-instrument close on T1, paired-instrument close on T1) / variance(paired-instrument close on T1), using current and prior N1, N2, N3, N4, N5, or N6 observations; select the first window whose Dickey-Fuller test accepts the first difference of its regression residuals and that difference's one-bar lag, or zero if none
Calculation: Pair regression error = square root of the sum of squared differences between each selected candidate's fitted value and traded-instrument close on T1 over the current and prior selected window, divided by the selected window minus 2; zero if no window is selected
Long: chart-timeframe traded-instrument close crosses above pair regression value minus pair regression error
Short: chart-timeframe traded-instrument close crosses below pair regression value plus pair regression error
Exit: long, chart-timeframe traded-instrument close crosses above pair regression value
Exit: short, chart-timeframe traded-instrument close crosses below pair regression value