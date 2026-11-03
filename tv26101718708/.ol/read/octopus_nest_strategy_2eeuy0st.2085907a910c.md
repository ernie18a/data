Calculation: Signal source, high, low, and close = values from the signal timeframe, which is the chart timeframe by default; use the last completed bar by default, or the bar still forming when repainting is enabled
Calculation: EMA = exponential moving average of the signal source sampled from a higher timeframe; use the higher-timeframe bar still forming
Calculation: Momentum oscillator = linear regression, with zero offset, of [signal source − average of (average of the lookback highest high and lowest low, and the lookback simple moving average of close)] over the lookback
Calculation: Long stop = at entry, if the entry-bar low equals the lookback lowest low, entry-bar low × backup multiplier; otherwise lookback lowest low × stop multiplier
Calculation: Short stop = at entry, if the entry-bar high equals the lookback highest high, entry-bar high × (2 − backup multiplier); otherwise lookback highest high × (2 − stop multiplier)
Calculation: Long take-profit = entry price + (entry price − long stop) × risk-reward ratio
Calculation: Short take-profit = entry price × [1 − (short stop − entry price) / short stop × risk-reward ratio]
Long: No open position AND signal source > EMA AND signal source crosses above PSAR AND momentum oscillator crosses above zero
Short: No open position AND signal source < EMA AND signal source crosses below PSAR AND momentum oscillator crosses below zero
Exit: Long, close crosses below long stop OR close crosses above long take-profit
Exit: Short, close crosses above short stop OR close crosses below short take-profit