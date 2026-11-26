Calculation: selected moving average = the moving-average method selected by the MA-type parameter, applied to the source-price parameter using the MA-lookback parameter; the double-SMA method uses close
Calculation: bullish engulfing = close > open AND close[1] < open[1] AND close > open[1] AND abs(close - open) > abs(close[1] - open[1])
Calculation: bearish engulfing = close < open AND close[1] > open[1] AND close < open[1] AND abs(close - open) > abs(close[1] - open[1])
Calculation: bullish alignment count = (1 if barssince(bullish engulfing) < barssince(bearish engulfing), otherwise 0) + (1 if barssince(source price crosses above selected moving average) < barssince(source price crosses below selected moving average), otherwise 0)
Calculation: bearish alignment count = (1 if barssince(bearish engulfing) < barssince(bullish engulfing), otherwise 0) + (1 if barssince(source price crosses below selected moving average) < barssince(source price crosses above selected moving average), otherwise 0)
Calculation: bars since bullish alignment onset = barssince(bullish alignment count == 2 AND bullish alignment count[1] < 2)
Calculation: bars since bearish alignment onset = barssince(bearish alignment count == 2 AND bearish alignment count[1] < 2)
Long: crossunder(bars since bullish alignment onset, bars since bearish alignment onset)
Short: crossover(bars since bullish alignment onset, bars since bearish alignment onset)
Calculation: bars since long signal = barssince(crossunder(bars since bullish alignment onset, bars since bearish alignment onset))
Calculation: bars since short signal = barssince(crossover(bars since bullish alignment onset, bars since bearish alignment onset))
Exit: long, close[1] < selected moving average
Exit: short, close[1] > selected moving average
Exit: long, bars since short signal > bars since long signal AND (high >= entry price + profit-target parameter OR low <= entry price - stop-distance parameter)
Exit: short, bars since short signal < bars since long signal AND (low <= entry price - profit-target parameter OR high >= entry price + stop-distance parameter)