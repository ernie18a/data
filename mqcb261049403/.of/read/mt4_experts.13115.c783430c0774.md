Calculation: Four Heikin-Ashi screens = Heikin-Ashi open and close on the chart timeframe's last completed bar and on the still-forming bars of three successively higher timeframes.
Calculation: Long trailing stop = the highest rounded price minus the trailing distance observed since entry for which the resulting stop exceeds the entry price by more than half a price point; active only when trailing is enabled.
Calculation: Short trailing stop = the lowest rounded price plus the trailing distance observed since entry for which the resulting stop is below the entry price by more than half a price point; active only when trailing is enabled.
Long: Heikin-Ashi close > Heikin-Ashi open on any one of the four screens.
Short: Heikin-Ashi close < Heikin-Ashi open on any one of the four screens.
Long: Heikin-Ashi close > Heikin-Ashi open on all four screens.
Short: Heikin-Ashi close < Heikin-Ashi open on all four screens.
Exit: long, low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance OR low <= active long trailing stop.
Exit: short, high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance OR high >= active short trailing stop.