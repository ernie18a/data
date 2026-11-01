Calculation: Step RSI = For each step size, calculate RSI of close on the selected timeframe. Initialize the previous lower boundary to positive infinity, the previous upper boundary to negative infinity, and trend to zero. On each bar set lower = RSI - 2 × step size and upper = RSI + 2 × step size. If RSI > previous upper, set trend to positive; if RSI < previous lower, set trend to negative; otherwise retain trend. If trend is positive, replace lower with max(lower, previous lower) and output lower + step size. If trend is negative, replace upper with min(upper, previous upper) and output upper - step size. Save both boundaries for the next bar. The fast Step RSI uses a smaller step size than the slow Step RSI. Long and short systems may use independently configured RSI periods, step sizes and timeframes. Use the last completed bar of the higher timeframe, or the selected signal bar still forming when configured; on the chart timeframe use the corresponding completed or forming bar.
Long: Fast Step RSI > slow Step RSI
Short: Fast Step RSI < slow Step RSI
Long: Fast Step RSI > slow Step RSI AND previous fast Step RSI <= previous slow Step RSI
Short: Fast Step RSI < slow Step RSI AND previous fast Step RSI >= previous slow Step RSI
Exit: long, fast Step RSI < slow Step RSI
Exit: short, fast Step RSI > slow Step RSI
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance