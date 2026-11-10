Calculation: Swing state and extremes = Initialize state to neutral and extremes to the first bar's high and low. On each bar, first update the high extreme to the maximum of itself and high, and the low extreme to the minimum of itself and low. If state is neutral or short, high extreme minus low is at least the minimum move, and close > open, set state to long and reset both extremes to the current high and low. Otherwise, if state is neutral or long, high minus low extreme is at least the minimum move, and close < open, set state to short and reset both extremes to the current high and low. State changes occur even when the optional EMA filter rejects a signal.
Long: Swing state changes to long AND (EMA filter disabled OR close > long-term EMA of close)
Short: Swing state changes to short AND (EMA filter disabled OR close < long-term EMA of close)
Long: Short-term EMA of close crosses above session VWAP of close
Short: Short-term EMA of close crosses below session VWAP of close
Long: Low > high two bars ago
Short: High < low two bars ago
Long: A pivot low of low is confirmed using equal left and right lookbacks
Short: A pivot high of high is confirmed using equal left and right lookbacks