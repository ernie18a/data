Calculation: Voted volume accumulation = Voted volume accumulation[1] + volume * ((high > high[1] ? 1 : high < high[1] ? -1 : 0) + (low > low[1] ? 1 : low < low[1] ? -1 : 0) + (close > close[1] ? 1 : close < close[1] ? -1 : 0))
Long: Voted volume accumulation > 0
Short: Voted volume accumulation < 0