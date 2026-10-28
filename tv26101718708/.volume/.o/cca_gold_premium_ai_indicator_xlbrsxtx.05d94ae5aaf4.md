Calculation: EMA = exponential moving average of close; use three lookbacks ordered shortest, intermediate, longest.
Calculation: RSI = relative strength index of close.
Calculation: Confirmed swing high/low = high/low pivot with equal left and right lookbacks; use the latest confirmed pivot and its bar.
Calculation: Bullish order block = on a close crossing above the latest confirmed swing high, use the latest confirmed swing low bar as the anchor; scan up to six bars from that anchor toward the current bar for the first bearish bar whose low is below the anchor low times 1.01, and use that bar’s high and low as the zone bounds; otherwise use the anchor bar’s high and low. Remove the zone when close falls below its lower bound.
Calculation: Bearish order block = on a close crossing below the latest confirmed swing low, use the latest confirmed swing high bar as the anchor; scan up to six bars from that anchor toward the current bar for the first bullish bar whose high is above the anchor high times 0.99, and use that bar’s high and low as the zone bounds; otherwise use the anchor bar’s high and low. Remove the zone when close rises above its upper bound.
Calculation: Bullish order-block rejection = low <= an active bullish order block’s upper bound AND close >= its lower bound AND close > open.
Calculation: Bearish order-block rejection = high >= an active bearish order block’s lower bound AND close <= its upper bound AND close < open.
Calculation: Bullish fair value gap = current low > high two bars earlier; remove it when close falls below its lower bound.
Calculation: Bearish fair value gap = low two bars earlier > current high; remove it when close rises above its upper bound.
Calculation: Bullish bias score = count of: close > open, shortest EMA > intermediate EMA, close > VWAP, close > longest EMA.
Long: close crosses above the latest confirmed swing high.
Long: current low > high two bars earlier.
Long: (RSI crosses above its oversold level AND (shortest EMA > intermediate EMA OR bullish bias score >= 2) OR bullish order-block rejection AND shortest EMA > intermediate EMA) AND current bar is more than five bars after the last long or short signal.
Short: close crosses below the latest confirmed swing low.
Short: low two bars earlier > current high.
Short: (RSI crosses below its overbought level AND (shortest EMA <= intermediate EMA OR bullish bias score <= 2) OR bearish order-block rejection AND shortest EMA <= intermediate EMA) AND current bar is more than five bars after the last long or short signal.