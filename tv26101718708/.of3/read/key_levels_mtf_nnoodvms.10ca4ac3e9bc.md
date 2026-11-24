Calculation: bias 0.618 level = highest(high, swing lookback, T1) - (highest(high, swing lookback, T1) - lowest(low, swing lookback, T1)) × retracement ratio, calculated on T1 bars and sampled on chart bars using the last completed T1 bar historically and the still-forming T1 bar in real time
Long: On chart bars, bias zone enabled AND crossover(close, bias 0.618 level)
Short: On chart bars, bias zone enabled AND crossunder(close, bias 0.618 level)
Calculation: upper ATR extreme = SMA(close, basis lookback) + ATR(ATR lookback) × ATR multiplier, calculated on T2 bars (or chart bars when T2 is the chart timeframe) and sampled on chart bars using the last completed T2 bar historically and the still-forming T2 bar in real time
Calculation: lower ATR extreme = SMA(close, basis lookback) - ATR(ATR lookback) × ATR multiplier, calculated on T2 bars (or chart bars when T2 is the chart timeframe) and sampled on chart bars using the last completed T2 bar historically and the still-forming T2 bar in real time
Short: On chart bars, ATR extremes enabled AND crossover(close, upper ATR extreme)
Long: On chart bars, ATR extremes enabled AND crossunder(close, lower ATR extreme)