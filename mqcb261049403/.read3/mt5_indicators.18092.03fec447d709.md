Calculation: smoothed price = selected moving-average method(applied price, method, lookback, phase)
Long: smoothed price > smoothed price[1]
Short: smoothed price < smoothed price[1]
Long: On chart bars, smoothed price(T1, bar still forming) > smoothed price(T1, last completed bar)
Short: On chart bars, smoothed price(T1, bar still forming) < smoothed price(T1, last completed bar)