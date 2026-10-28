Calculation: Confirmed price pivots = A pivot high/low is confirmed when its bar’s high/low is the highest/lowest across equal-length bars before and after it; update the last high/low at confirmation.
Calculation: Structure state = Bias starts neutral, changes to bullish when a confirmed pivot high exceeds the prior pivot high, and changes to bearish when a confirmed pivot low is below the prior pivot low; otherwise it persists. Signal availability becomes true at each confirmed price pivot and false after a retracement entry signal.
Calculation: Structural leg retracement level = In bullish bias, last pivot high − (absolute difference between last pivot high and last pivot low × retracement fraction); in bearish bias, last pivot low + (that absolute difference × retracement fraction).
Calculation: RSI divergence pivots = RSI pivots are confirmed using equal-length bars before and after the pivot; compare each new pivot with the prior pivot of the same type and its corresponding price high/low.
Long: Signal available AND last pivot high and last pivot low exist AND bullish structure bias AND low < bullish structural leg retracement level AND close > open AND close > previous bar high
Long: Confirmed RSI pivot low AND pivot-bar low < prior RSI pivot-low bar’s low AND pivot RSI < prior pivot RSI
Long: low < previous completed daily low AND close > previous completed daily low
Short: Signal available AND last pivot high and last pivot low exist AND bearish structure bias AND high > bearish structural leg retracement level AND close < open AND close < previous bar low
Short: Confirmed RSI pivot high AND pivot-bar high > prior RSI pivot-high bar’s high AND pivot RSI < prior pivot RSI
Short: high > previous completed daily high AND close < previous completed daily high