Calculation: Pre-session high = highest high from local day start through the start of the configured trade window
Calculation: Pre-session low = lowest low from local day start through the start of the configured trade window
Calculation: Session midpoint = (pre-session high + pre-session low) / 2
Long: close > the current local day's midnight open
Short: close < the current local day's midnight open
Long: within the configured trade window and no sweep is active, previous close > previous trading day's low AND open > previous trading day's low AND low < previous trading day's low AND close > previous trading day's low, OR within the configured trade window and no sweep is active, previous close > pre-session low AND open > pre-session low AND low < pre-session low AND close > pre-session low
Short: within the configured trade window and no sweep is active, previous close < previous trading day's high AND open < previous trading day's high AND high > previous trading day's high AND close < previous trading day's high, OR within the configured trade window and no sweep is active, previous close < pre-session high AND open < pre-session high AND high > pre-session high AND close < pre-session high
Long: a bullish sweep is active
Short: a bearish sweep is active
Long: close[1] > open[1] AND high[1] - low[1] > ATR(lookback)[1] * displacement multiplier
Short: close[1] < open[1] AND high[1] - low[1] > ATR(lookback)[1] * displacement multiplier
Long: low > high[2]
Short: high < low[2]
Long: low < session midpoint
Short: high > session midpoint
Long: within the configured trade window, after a bullish sweep on an earlier bar, low > high[2] AND (displacement filter disabled OR close[1] > open[1] AND high[1] - low[1] > ATR(lookback)[1] * displacement multiplier) AND (premium/discount filter disabled OR low < session midpoint) AND (one-FVG-per-sweep option disabled OR no bullish FVG has printed for this sweep)
Short: within the configured trade window, after a bearish sweep on an earlier bar, high < low[2] AND (displacement filter disabled OR close[1] < open[1] AND high[1] - low[1] > ATR(lookback)[1] * displacement multiplier) AND (premium/discount filter disabled OR high > session midpoint) AND (one-FVG-per-sweep option disabled OR no bearish FVG has printed for this sweep)