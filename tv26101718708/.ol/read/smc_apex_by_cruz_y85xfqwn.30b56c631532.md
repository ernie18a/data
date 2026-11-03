Calculation: Bullish FVG = current low > high two bars ago, with gap size as a percentage of high two bars ago >= minimum FVG size
Calculation: Bearish FVG = current high < low two bars ago, with gap size as a percentage of current high >= minimum FVG size
Calculation: Bullish structure break = a close above the latest confirmed swing high, when the prior close was at or below the prior bar’s latest confirmed swing high
Calculation: Bearish structure break = a close below the latest confirmed swing low, when the prior close was at or above the prior bar’s latest confirmed swing low
Calculation: Bull trend = close > long-term EMA
Calculation: Bear trend = close < long-term EMA
Long: Bullish structure break AND (bull trend OR bear trend) [bullish BOS/CHoCH marking]; OR armed by that break, a bullish FVG has been recorded, current low <= its top, close >= its bottom, bull trend, close > the highest high of the preceding shorter lookback, cooldown since the last signal has elapsed, and the daily signal limit has not been reached
Short: Bearish structure break AND (bear trend OR bull trend) [bearish BOS/CHoCH marking]; OR armed by that break, a bearish FVG has been recorded, current high >= its bottom, close <= its top, bear trend, close < the lowest low of the preceding shorter lookback, cooldown since the last signal has elapsed, and the daily signal limit has not been reached