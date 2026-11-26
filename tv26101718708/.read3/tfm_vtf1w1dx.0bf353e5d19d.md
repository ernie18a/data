Calculation: T1 = chart timeframe multiplied by a parameter.
Calculation: Upper level = on T1 bars, max(high, high[1]) when close[1] > open[1] AND close[0] < open[0], otherwise missing; use the latest nonmissing T1 value delayed by one chart bar and forward-fill it on chart bars. The condition uses the previous completed T1 bar and the current still-forming T1 bar.
Calculation: Lower level = on T1 bars, min(low, low[1]) when close[1] < open[1] AND close[0] > open[0], otherwise missing; use the latest nonmissing T1 value delayed by one chart bar and forward-fill it on chart bars. The condition uses the previous completed T1 bar and the current still-forming T1 bar.
Calculation: Trend state = 1 on crossunder(close, lower level), -1 on crossover(close, upper level), otherwise the previous trend state.
Long: close > upper level.
Short: close < lower level AND long/short mode is enabled.
Exit: long, close < lower level AND long/short mode is disabled.
Long: trend state > 0.
Short: trend state < 0.
Long: close > lower level.
Short: close <= lower level AND close < upper level.