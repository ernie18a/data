Calculation: Chart smoothed price = MovingAverage(chart applied price, chart smoothing method, chart smoothing lookback, chart phase) + chart vertical shift in points
Calculation: Chart change = Chart smoothed price - Chart smoothed price[1]
Calculation: Chart change deviation = population standard deviation(Chart change, chart volatility lookback)
Calculation: Chart lower threshold = round(chart lower multiplier × Chart change deviation, price precision + 2)
Calculation: Chart upper threshold = round(chart higher multiplier × Chart change deviation, price precision + 2)
Long: Chart smoothed price > Chart smoothed price[1]
Short: Chart smoothed price < Chart smoothed price[1]
Long: round(Chart change, price precision + 2) > Chart lower threshold AND round(Chart change, price precision + 2) <= Chart upper threshold
Long: round(Chart change, price precision + 2) > Chart upper threshold
Short: round(Chart change, price precision + 2) < -Chart lower threshold AND round(Chart change, price precision + 2) >= -Chart upper threshold
Short: round(Chart change, price precision + 2) < -Chart upper threshold
Calculation: T1 smoothed price = MovingAverage(T1 applied price, T1 smoothing method, T1 smoothing lookback, T1 phase) + T1 vertical shift in points, calculated on T1 bars using the still-forming bar and copied to chart bars
Calculation: T1 change = T1 smoothed price - T1 smoothed price[1]
Calculation: T1 change deviation = population standard deviation(T1 change, T1 volatility lookback)
Calculation: T1 lower threshold = round(T1 lower multiplier × T1 change deviation, price precision + 2)
Calculation: T1 upper threshold = round(T1 higher multiplier × T1 change deviation, price precision + 2)
Long: On chart bars using copied T1 values, round(T1 change, price precision + 2) > T1 lower threshold AND round(T1 change, price precision + 2) <= T1 upper threshold
Long: On chart bars using copied T1 values, round(T1 change, price precision + 2) > T1 upper threshold
Short: On chart bars using copied T1 values, round(T1 change, price precision + 2) < -T1 lower threshold AND round(T1 change, price precision + 2) >= -T1 upper threshold
Short: On chart bars using copied T1 values, round(T1 change, price precision + 2) < -T1 upper threshold