Calculation: Smoothed RSI = RSI of close, smoothed with a moving average
Calculation: MACD histogram = MACD line minus signal line, using a shorter and a longer close lookback
Calculation: Histogram expansion = absolute MACD histogram is greater than its value on each of the previous two bars
Calculation: ADX and directional indicators = trend strength, positive directional indicator, and negative directional indicator derived from high, low, and close
Calculation: Rate of change = percentage change in close over a lookback
Calculation: Volume surge = volume exceeds its moving average times a configurable multiplier
Calculation: Momentum score = weighted bullish votes minus weighted bearish votes: bullish votes for smoothed RSI rising on each of the previous two bars and above 50; bearish votes when that RSI is not rising and below 50; bullish votes for positive expanding MACD histogram, or otherwise for a MACD line crossing above its signal line; bearish votes for negative expanding MACD histogram; bullish or bearish votes when ADX exceeds its threshold, rises on each of the previous two bars, and the positive or negative directional indicator respectively leads; bullish votes for rising positive rate of change, bearish votes when rate of change is negative and not rising; add a volume-surge bonus to whichever side's votes lead before the bonus
Calculation: Smoothed momentum score = EMA of momentum score
Calculation: Bullish divergence = at a confirmed price pivot low, the smoothed momentum score pivot is higher and the price low is lower than at the preceding confirmed price pivot low, with pivot spacing within configured minimum and maximum bounds
Calculation: Bearish divergence = at a confirmed price pivot high, the smoothed momentum score pivot is lower and the price high is higher than at the preceding confirmed price pivot high, with pivot spacing within configured minimum and maximum bounds
Long: Smoothed momentum score crosses above the building threshold OR bullish divergence
Short: Smoothed momentum score crosses below the fading threshold OR bearish divergence