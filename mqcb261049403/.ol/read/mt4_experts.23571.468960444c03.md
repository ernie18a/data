Calculation: Slow stochastic = slower stochastic signal line on the chart timeframe, using the last completed bar
Calculation: Fast stochastic = faster stochastic main line on the chart timeframe, using the last completed bar
Calculation: Short-period moving average = linear weighted moving average of typical price on the chart timeframe, using the bar still forming
Calculation: Long-period moving average = linear weighted moving average of typical price on the chart timeframe, with a longer period than the short-period moving average, using the bar still forming
Long: Slow stochastic < Fast stochastic AND RSI(14) on the chart timeframe, last completed bar > 50 AND Short-period moving average > Long-period moving average AND Low[2] < High[1] AND absolute distance between current bid and Close[2] > the retrace threshold
Short: Slow stochastic > Fast stochastic AND RSI(14) on the chart timeframe, last completed bar < 50 AND Short-period moving average < Long-period moving average AND Low[1] < High[2] AND absolute distance between current ask and Close[1] > the retrace threshold
Exit: long, low <= entry price minus the stop-loss distance OR high >= entry price plus the stop-loss distance multiplied by the reward ratio
Exit: short, high >= entry price plus the stop-loss distance OR low <= entry price minus the stop-loss distance multiplied by the reward ratio