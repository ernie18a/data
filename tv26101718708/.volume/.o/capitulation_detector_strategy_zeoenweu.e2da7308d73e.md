Calculation: Slow EMA = EMA of close with a longer lookback than the fast EMA
Calculation: Fast EMA = EMA of close with a shorter lookback than the slow EMA
Calculation: ATR = Average True Range
Calculation: Volume spike = current volume >= volume moving average × spike multiplier
Calculation: Body expansion = abs(close − open) >= moving average of abs(close − open) × body multiplier
Calculation: Bullish trend persistence = bars since close was above the slow EMA >= trend minimum
Calculation: Bearish trend persistence = bars since close was below the slow EMA >= trend minimum
Calculation: Bullish acceleration = bars since close was above the fast EMA >= acceleration minimum AND bullish trend persistence
Calculation: Bearish acceleration = bars since close was below the fast EMA >= acceleration minimum AND bearish trend persistence
Calculation: Bullish extension = close < slow EMA AND abs(close − slow EMA) / ATR >= extension threshold
Calculation: Bearish extension = close > slow EMA AND abs(close − slow EMA) / ATR >= extension threshold
Calculation: Bullish multi-leg = at least three qualifying swing lows; a qualifying swing low has low < each of the prior two lows, prior low < the low two bars ago, and prior low < the low three bars ago. Count a swing low when its low is below the last counted swing low; otherwise reset the count to one. Reset count and last counted swing low when close crosses above the slow EMA.
Calculation: Bearish multi-leg = at least three qualifying swing highs; a qualifying swing high has high > each of the prior two highs, prior high > the high two bars ago, and prior high > the high three bars ago. Count a swing high when its high is above the last counted swing high; otherwise reset the count to one. Reset count and last counted swing high when close crosses below the slow EMA.
Calculation: Bullish score = sum of the six true conditions: bullish trend persistence, bullish acceleration, volume spike, body expansion, bullish extension, bullish multi-leg
Calculation: Bearish score = sum of the six true conditions: bearish trend persistence, bearish acceleration, volume spike, body expansion, bearish extension, bearish multi-leg
Long: bullish score >= minimum score AND close < open AND close < slow EMA AND (volume spike required is disabled OR volume spike) AND (time filter is disabled OR bar time is within the configured session window) AND position is flat
Short: bearish score >= minimum score AND close > open AND close > slow EMA AND (volume spike required is disabled OR volume spike) AND (time filter is disabled OR bar time is within the configured session window) AND position is flat
Exit: Long, low <= signal bar close − ATR × stop multiple OR high >= signal bar close + ATR × target multiple OR trailing stop is enabled and the trailing stop is hit
Exit: Short, high >= signal bar close + ATR × stop multiple OR low <= signal bar close − ATR × target multiple OR trailing stop is enabled and the trailing stop is hit