Calculation: Bullish stack = EMA(source price, shortest lookback) > EMA(source price, middle lookback) AND EMA(source price, middle lookback) > EMA(source price, longest lookback)
Calculation: Bearish stack = EMA(source price, shortest lookback) < EMA(source price, middle lookback) AND EMA(source price, middle lookback) < EMA(source price, longest lookback)
Calculation: Ribbon width = ABS(EMA(source price, shortest lookback) - EMA(source price, longest lookback))
Calculation: Squeeze = Ribbon width < SMA(Ribbon width, squeeze lookback) * squeeze ratio
Calculation: Squeeze release = NOT Squeeze AND Squeeze[1]
Long: EMA(source price, shortest lookback) crosses above EMA(source price, middle lookback) OR EMA(source price, shortest lookback) crosses above EMA(source price, longest lookback) OR EMA(source price, middle lookback) crosses above EMA(source price, longest lookback)
Short: EMA(source price, shortest lookback) crosses below EMA(source price, middle lookback) OR EMA(source price, shortest lookback) crosses below EMA(source price, longest lookback) OR EMA(source price, middle lookback) crosses below EMA(source price, longest lookback)
Long: Bullish stack AND NOT Bullish stack[1]
Short: Bearish stack AND NOT Bearish stack[1]
Long: Squeeze release AND Bullish stack
Short: Squeeze release AND Bearish stack
Long: Bullish stack AND close > EMA(source price, shortest lookback)
Short: Bearish stack AND close < EMA(source price, shortest lookback)