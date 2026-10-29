Calculation: Signal-bar midpoint = (high + low) / 2 of the last completed bar on the configured signal timeframe, which may be higher or lower than the chart timeframe.
Calculation: Signal-bar range = high - low of that same bar.
Calculation: Trail distance = (high - low) of the last completed bar on the configured trailing timeframe, which may be higher or lower than the chart timeframe, multiplied by the trailing factor.
Long: Signal-bar close > signal-bar midpoint AND ask > signal-bar high + spread
Short: Signal-bar close < signal-bar midpoint AND bid < signal-bar low
Exit: long, bid <= stop-loss OR bid >= take-profit
Exit: short, ask >= stop-loss OR ask <= take-profit