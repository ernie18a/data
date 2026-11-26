Calculation: Smoothed source = EMA(selected price field, smoothing lookback) on chart bars
Calculation: Fast EMA = if fixed timeframe is enabled, EMA(EMA(selected price field, fast lookback, T1, bar still forming), smoothing lookback on chart bars) using T1 values on chart bars; otherwise EMA(Smoothed source, fast lookback) on chart bars
Calculation: Slow EMA = if fixed timeframe is enabled, EMA(EMA(selected price field, slow lookback, T1, bar still forming), smoothing lookback on chart bars) using T1 values on chart bars; otherwise EMA(Smoothed source, slow lookback) on chart bars
Calculation: Baseline EMA = if fixed baseline is enabled, EMA(EMA(selected price field, baseline lookback, T1, bar still forming), smoothing lookback on chart bars) using T1 values on chart bars; otherwise EMA(Smoothed source, baseline lookback) on chart bars
Calculation: Green condition = Fast EMA > Slow EMA AND Smoothed source > Fast EMA
Calculation: Red condition = Fast EMA < Slow EMA AND Smoothed source < Fast EMA
Calculation: Green transition = Green condition AND previous chart bar's Green condition is false
Calculation: Red transition = Red condition AND previous chart bar's Red condition is false
Calculation: Bullish state = bars since Green transition < bars since Red transition
Calculation: Bearish state = bars since Red transition < bars since Green transition
Calculation: StochRSI K = StochRSI K(selected StochRSI source, RSI lookback, stochastic lookback, K smoothing)
Calculation: StochRSI D = SMA(StochRSI K, D smoothing)
Calculation: Long oscillator score = higher score parameter when StochRSI K crosses above StochRSI D AND StochRSI D < oversold threshold; lower score parameter when StochRSI K crosses above StochRSI D AND StochRSI D > oversold threshold; otherwise no signal
Calculation: Short oscillator score = higher score parameter when StochRSI K crosses below StochRSI D AND StochRSI D > overbought threshold; lower score parameter when StochRSI K crosses below StochRSI D AND StochRSI D < overbought threshold; otherwise no signal
Long: Green condition
Short: Red condition
Long: Bearish state[1] AND Green transition
Short: Bullish state[1] AND Red transition
Long: Bullish state AND Long oscillator score > signal threshold
Short: Bearish state AND Short oscillator score > signal threshold
Long: Bearish state[1] AND Green transition AND Smoothed source >= Baseline EMA AND Fast EMA > Slow EMA
Short: Bullish state[1] AND Red transition AND Smoothed source <= Baseline EMA AND Fast EMA < Slow EMA
Exit: long, Fast EMA < Slow EMA
Exit: short, Fast EMA > Slow EMA