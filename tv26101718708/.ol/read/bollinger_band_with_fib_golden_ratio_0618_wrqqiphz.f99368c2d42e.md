Calculation: EMA = exponential moving average of close; the long-term lookback is longer than the short-term lookback
Calculation: Lower Bollinger Fib band = VWMA(HLC3, lookback) − 0.618 × multiplier × standard deviation(HLC3, lookback)
Calculation: Upper Bollinger Fib band = VWMA(HLC3, lookback) + 0.618 × multiplier × standard deviation(HLC3, lookback)
Long: short-term EMA > long-term EMA AND (close < lower Bollinger Fib band OR low <= lower Bollinger Fib band)
Exit: long, (close > upper Bollinger Fib band AND previous close <= previous upper Bollinger Fib band) OR close < entry price × (1 − stop-loss percentage / 100)