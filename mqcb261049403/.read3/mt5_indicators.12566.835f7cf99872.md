Calculation: leading line(price, alpha) = 2*price + (alpha - 2)*price[1] + (1 - alpha)*leading line[1]
Long: EMA(median price, lookback) crosses below leading line(median price, chart alpha)
Short: EMA(median price, lookback) crosses above leading line(median price, chart alpha)
Calculation: T1 trend state = +1 after the latest T1 EMA(median price, lookback) crosses below leading line(median price, T1 alpha), -1 after it crosses above, and 0 before either; calculated on T1 bars, with chart bars using the state at the selected T1 bar, including while it is forming
Long: T1 trend state = +1
Short: T1 trend state = -1