Calculation: Opening-range high = highest high of chart bars during the opening-range duration after session open
Calculation: Opening-range low = lowest low of chart bars during the opening-range duration after session open
Calculation: Long stop = lowest low of chart bars over the stop lookback − ATR(high, low, close, ATR lookback) × stop multiplier at the signal bar, when stop levels are enabled
Calculation: Short stop = highest high of chart bars over the stop lookback + ATR(high, low, close, ATR lookback) × stop multiplier at the signal bar, when stop levels are enabled
Calculation: Long target = signal-bar close + (signal-bar close − long stop) × risk/reward parameter
Calculation: Short target = signal-bar close − (short stop − signal-bar close) × risk/reward parameter
Long: On confirmed chart-bar close, close crosses above opening-range high OR close crosses above high(T1, last completed bar), AND close > open, AND (momentum and volume filters are ignored OR (RSI(close, momentum lookback) > long momentum threshold AND volume > VWMA(close, volume lookback) × volume threshold))
Short: On confirmed chart-bar close, close crosses below opening-range low OR close crosses below low(T1, last completed bar), AND close < open, AND (momentum and volume filters are ignored OR (RSI(close, momentum lookback) < short momentum threshold AND volume > VWMA(close, volume lookback) × volume threshold))
Exit: Long, stop levels are enabled AND (close <= long stop OR close >= long target)
Exit: Short, stop levels are enabled AND (close >= short stop OR close <= short target)
Exit: Long, market is not always open AND chart-bar time >= end-of-day cutoff parameter
Exit: Short, market is not always open AND chart-bar time >= end-of-day cutoff parameter
Long: At chart-bar close, (chart close > opening-range high OR chart close > previous T1-period high) AND (confirmation filter disabled OR (RSI(chart close, RSI period) > upper RSI threshold AND chart volume > SMA(chart volume, volume averaging period) × volume multiplier AND chart close > chart open))
Short: At chart-bar close, (chart close < opening-range low OR chart close < previous T1-period low) AND (confirmation filter disabled OR (RSI(chart close, RSI period) < lower RSI threshold AND chart volume > SMA(chart volume, volume averaging period) × volume multiplier AND chart close < chart open))