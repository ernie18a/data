Calculation: Selected price = the selected one of close, open, high, low, (high + low) / 2, (close + high + low) / 3, (2 * close + high + low) / 4, (open + close) / 2, (open + close + high + low) / 4, close > open ? high : close < open ? low : close, or close > open ? (high + close) / 2 : close < open ? (low + close) / 2 : close; otherwise close
Calculation: Chart spread = Selected price - Bollinger Bands(Bollinger price, Bollinger lookback, deviation, selected line) - 2 * Moving Average(MA price, MA lookback, MA method) + high + low
Long: Chart spread > 0
Short: Chart spread < 0
Calculation: T1 spread = Selected price(T1 bar still forming) - Bollinger Bands(Bollinger price, Bollinger lookback, deviation, selected line, T1 bar still forming) - 2 * Moving Average(MA price, MA lookback, MA method, T1 bar still forming) + high(T1 bar still forming) + low(T1 bar still forming)
Long: On chart bars using values from the T1 bar still forming, T1 spread > 0
Short: On chart bars using values from the T1 bar still forming, T1 spread < 0