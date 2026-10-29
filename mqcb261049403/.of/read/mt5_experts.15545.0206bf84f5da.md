Calculation: Average High = mean of the highest high in each of the lookback’s successive signal-timeframe intervals; the signal timeframe is lower than the chart timeframe.
Calculation: Average Low = mean of the lowest low in each of the lookback’s successive signal-timeframe intervals.
Calculation: Trend state = bullish when the signal-timeframe close is above Average High, bearish when below Average Low, otherwise carry forward the prior state.
Long: On the last completed signal-timeframe bar, Trend state is bullish AND the prior bar’s Trend state was not bullish.
Short: On the last completed signal-timeframe bar, Trend state is bearish AND the prior bar’s Trend state was not bearish.
Exit: long, Trend state is bearish.
Exit: short, Trend state is bullish.