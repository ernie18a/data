Calculation: Chart EMA = EMA of chart-timeframe closes.
Calculation: Trend-timeframe close and EMA = close and EMA of the last completed bar on a timeframe higher than the chart timeframe; the EMA uses the same lookback as the chart EMA.
Calculation: Setup-timeframe close and EMA = close and EMA of the last completed bar on a timeframe higher than the chart timeframe; the EMA uses the same lookback as the chart EMA.
Calculation: Long stop = lowest low over the swing lookback on chart-timeframe bars, including the current bar.
Calculation: Short stop = highest high over the swing lookback on chart-timeframe bars, including the current bar.
Calculation: Long target = signal-bar close + risk-reward multiple × (signal-bar close − long stop).
Calculation: Short target = signal-bar close − risk-reward multiple × (short stop − signal-bar close).
Long: bar time is within the configured session AND volume > chart-timeframe volume SMA AND low <= chart EMA AND trend-timeframe close > trend-timeframe EMA AND setup-timeframe close > setup-timeframe EMA AND close > open AND close > previous chart-timeframe bar high AND close > long stop AND position is flat or short.
Short: bar time is within the configured session AND volume > chart-timeframe volume SMA AND high >= chart EMA AND trend-timeframe close < trend-timeframe EMA AND setup-timeframe close < setup-timeframe EMA AND close < open AND close < previous chart-timeframe bar low AND short stop > close AND position is flat or long.
Exit: Long, low <= long stop OR high >= long target.
Exit: Short, high >= short stop OR low <= short target.