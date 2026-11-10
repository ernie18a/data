Calculation: Trend direction = the direction of the most recent unequal comparison of the shorter-period and longer-period close EMAs; initially neither direction is active. Both EMAs use the still-forming bar of the same fixed timeframe, which may be higher than, lower than, or equal to the chart timeframe.
Calculation: Adjusted Williams %R = Williams %R with an exact zero replaced by a negative constant. The current value uses the still-forming bar of a fixed timeframe, which may be higher than, lower than, or equal to the chart timeframe; the previous value uses its last completed bar.
Long: Trend direction is upward AND current adjusted Williams %R > buy threshold AND previous adjusted Williams %R < buy threshold AND previous adjusted Williams %R < 0 AND current chart-bar close-based CCI < buy CCI threshold.
Short: Trend direction is downward AND current adjusted Williams %R < sell threshold AND previous adjusted Williams %R > sell threshold AND previous adjusted Williams %R < 0 AND current chart-bar close-based CCI > sell CCI threshold.
Exit: long, current shorter-period EMA < current longer-period EMA.
Exit: short, current shorter-period EMA > current longer-period EMA.
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.