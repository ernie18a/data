Calculation: One-bar return = (current close - previous bar close) / previous bar close
Calculation: Volume average = simple moving average of volume over its lookback
Calculation: Prior-lookback highest high = highest high over the lookback bars before the current bar
Calculation: Pump = RSI is at or above its pump threshold OR (volume is greater than the volume average times its multiplier AND one-bar return is greater than its pump threshold)
Calculation: Bars since pump ended = 0 on the first bar after Pump changes from true to false; otherwise increment by one each bar
Short: Position is flat AND Pump is false AND RSI is at or below its cool-off threshold AND (one-bar return is at or below half the pump return threshold OR volume is at or below the volume average times 0.8 times its multiplier) AND bars since pump ended is at least the wait parameter
Short: Position is flat AND current high is greater than the prior-lookback highest high AND Pump is false
Exit: short, Pump is true OR close is at or below entry price times (1 - take-profit parameter) OR close is at or above entry price times (1 + stop-loss parameter)