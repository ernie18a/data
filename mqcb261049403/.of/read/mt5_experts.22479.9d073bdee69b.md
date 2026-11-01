Calculation: Channel = the open of the first bar whose hour equals the configured start hour on a new calendar day, plus or minus a fixed price offset; retain that open until the next such day.
Calculation: Signal bar = a selected bar on the indicator timeframe, which may be higher than, lower than, or equal to the chart timeframe; use either the last completed bar or the still-forming bar, according to the selected bar offset. The previous signal bar is the immediately preceding indicator-timeframe bar.
Long: chart-bar close > chart-timeframe channel upper bound
Short: chart-bar close < chart-timeframe channel lower bound
Long: signal-bar close > its channel upper bound AND previous signal-bar close <= its channel upper bound AND position side = flat
Short: signal-bar close < its channel lower bound AND previous signal-bar close >= its channel lower bound AND position side = flat
Exit: long, signal-bar close < its channel lower bound OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance OR elapsed time since entry > holding-time limit
Exit: short, signal-bar close > its channel upper bound OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance OR elapsed time since entry > holding-time limit