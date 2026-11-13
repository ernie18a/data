Calculation: PinnedEMA = EMA of close computed on bars of a fixed timeframe higher than the chart timeframe, using the higher-timeframe bar still forming (the one containing the current chart bar, with the current chart close as its provisional close); each pinned EMA has its own length and timeframe and is evaluated independently
Long: close >= PinnedEMA
Short: close < PinnedEMA