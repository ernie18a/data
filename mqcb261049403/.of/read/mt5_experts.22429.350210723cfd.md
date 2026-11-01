Calculation: Channel = the open of the first indicator-timeframe bar whose hour equals the configured start hour on a new day, plus and minus the same fixed price offset; retain these levels until the next qualifying bar.
Calculation: Indicator bars = chart-timeframe bars or higher-timeframe bars; for higher-timeframe signals use the last completed bar, or the still-forming bar if the signal-bar setting selects it. Each bar uses the channel in force on that bar.
Long: Indicator-bar close > channel upper level.
Short: Indicator-bar close < channel lower level.
Long: Signal-bar close > its channel upper level AND preceding indicator-bar close <= its channel upper level AND position side = flat.
Short: Signal-bar close < its channel lower level AND preceding indicator-bar close >= its channel lower level AND position side = flat.
Exit: long, signal-bar close < its channel lower level OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, signal-bar close > its channel upper level OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.