Calculation: Timeframe RSI = RSI of the selected price source on each independently selected timeframe; use the last completed bar for a higher timeframe and the last completed intrabar for a lower timeframe.
Calculation: Composite RSI = sum of each timeframe RSI multiplied by its weight, divided by the sum of weights; use the equilibrium level if the sum of weights is zero.
Calculation: Bullish count = number of timeframe RSI values at or above the RSI equilibrium level; bearish count = total number of timeframe RSI values minus bullish count.
Calculation: Consensus = absolute difference between bullish count and bearish count divided by the total number of timeframe RSI values.
Calculation: Momentum range level = lowest composite RSI over a lookback plus a chosen fraction of the difference between the highest and lowest composite RSI over that lookback.
Calculation: Probability score = weighted sum of consensus, capped absolute distance between the shorter and longer EMA of composite RSI, absolute distance of composite RSI from its equilibrium level, and a step score determined by which of several ordered momentum range levels composite RSI is at or above.
Long: Timeframe RSI >= RSI equilibrium level.
Short: Timeframe RSI < RSI equilibrium level.
Long: Bullish count > bearish count.
Short: Bearish count > bullish count.
Long: Composite RSI >= RSI equilibrium level.
Short: Composite RSI < RSI equilibrium level.
Long: Shorter EMA of composite RSI > longer EMA of composite RSI.
Short: Shorter EMA of composite RSI < longer EMA of composite RSI.
Long: Consensus >= trend consensus threshold AND shorter EMA of composite RSI > longer EMA of composite RSI AND probability score >= trend probability threshold AND composite RSI >= bullish trend threshold.
Short: Consensus >= trend consensus threshold AND shorter EMA of composite RSI < longer EMA of composite RSI AND probability score >= trend probability threshold AND composite RSI <= bearish trend threshold.