Calculation: CVDD = (realized market-cap close(T1, current bar while forming) − SMA(total-volume close, lookback parameter, T1, current bar while forming)) / scale parameter
Calculation: Upper band = CVDD × 10^(−(top-slope coefficient parameter × slope input parameter / normalization parameter) × chart-bar Unix time + (top-intercept coefficient parameter × intercept input parameter / normalization parameter))
Long: chart-bar time > start-time parameter AND CVDD is defined AND low(T1, current bar while forming), sampled on chart bars, <= CVDD
Short: chart-bar time > start-time parameter AND CVDD is defined AND high(T1, current bar while forming), sampled on chart bars, >= Upper band
Calculation: CVDD = (realized market capitalization (T1) - SMA(total volume (T1), P1)) / P2
Long: Bitcoin low (T1) <= CVDD AND CVDD is defined AND chart time > P7
Short: Bitcoin high (T1) >= CVDD * 10^(-P5 * P3 / 100 * chart time + P6 * P4 / 100) AND CVDD is defined AND chart time > P7