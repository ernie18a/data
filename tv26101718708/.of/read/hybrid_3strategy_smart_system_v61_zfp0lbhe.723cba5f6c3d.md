Calculation: EMA = exponential moving average of close; ATR = average true range; RSI = relative strength index; ADX = average directional index; volume average = simple moving average of volume; high volume = volume > volume average × volume multiplier
Calculation: Higher-timeframe close and EMA = close and EMA on a higher timeframe, using the current higher-timeframe bar (developing in real time, last available completed bar historically)
Calculation: Bull trend = close > EMA AND EMA > its value a lookback ago AND higher-timeframe close > higher-timeframe EMA AND session filter passes AND absolute distance from close to EMA ≤ ATR × distance limit
Calculation: Bear trend = close < EMA AND EMA < its value a lookback ago AND higher-timeframe close < higher-timeframe EMA AND session filter passes AND absolute distance from close to EMA ≤ ATR × distance limit
Calculation: Trending market = ADX > minimum AND absolute change in EMA over a lookback ≥ ATR × minimum slope; the slope lookback is shorter than the EMA trend lookback
Calculation: Bullish rejection candle = close > open AND lower wick ≥ body size × rejection ratio; bearish rejection candle = close < open AND upper wick ≥ body size × rejection ratio
Calculation: Bullish confirmation = close > open; bearish confirmation = close < open
Calculation: Bullish FVG = current low > high two bars ago; size = current low − high two bars ago. Bearish FVG = current high < low two bars ago; size = low two bars ago − current high
Calculation: Armed bullish/bearish FVG = a bullish/bearish FVG formed while the matching trend and trending-market conditions hold, with size ≥ ATR × minimum gap size; retain its bounds until touched after its formation bar or until its age exceeds the maximum
Calculation: FVG touch = after formation, current bar overlaps the armed gap
Calculation: FVG score = 20 for matching trend + 15 for matching higher-timeframe trend + 15 for trending market + 15 for FVG touch + 10 for matching confirmation candle + 10 for high volume + 15 × min(gap size / ATR, 2)
Calculation: Bull exhaustion bar = close < EMA AND high volume AND RSI < oversold threshold AND close > open AND lower wick > body size × wick ratio. Bear exhaustion bar = close > EMA AND high volume AND RSI > overbought threshold AND close < open AND upper wick > body size × wick ratio
Calculation: Armed volume trigger = high of most recent bull exhaustion bar for long, or low of most recent bear exhaustion bar for short; valid only on later bars and until its age exceeds the maximum
Calculation: Volume score = 15 if close is on the matching side of EMA + 20 if RSI is beyond the stricter oversold/overbought threshold, otherwise 10 + 20 for high volume + 15 if matching wick > body size, otherwise 8 + 15 if close has crossed the armed trigger + 10 for matching confirmation candle + 5 × min(volume / volume average, 2)
Calculation: Swing high/low = latest confirmed pivot high/low, each using equal left and right lookbacks
Calculation: Long break = close crosses above latest swing high while bull trend and trending-market conditions hold; short break = close crosses below latest swing low while bear trend and trending-market conditions hold
Calculation: Armed retest = after a long/short break, retain the broken swing level until retested or until its age exceeds the maximum
Calculation: Retest score = 20 for matching trend + 20 for trending market + 15 for matching higher-timeframe trend + 15 for retest (low ≤ long level / high ≥ short level) + 15 for close beyond the level in the trade direction + 10 for matching confirmation candle + 5 for high volume
Calculation: Cooldown passes = no prior entry, or bars since last entry > cooldown length
Calculation: FVG setup = enabled and matching trend and cooldown passes and armed FVG is touched and matching confirmation candle and close remains beyond the far gap boundary and FVG score ≥ score threshold
Calculation: Volume setup = enabled and cooldown passes and matching trigger is crossed by close on a later bar and matching confirmation candle and volume score ≥ score threshold
Calculation: Retest setup = enabled and cooldown passes and armed level is retested and close finishes beyond it in the trade direction and matching confirmation candle and retest score ≥ score threshold
Calculation: Long pending validity = signal has not expired AND absolute distance from close to pending entry ≤ ATR × entry-distance limit AND close ≥ EMA × proximity factor
Calculation: Short pending validity = signal has not expired AND absolute distance from close to pending entry ≤ ATR × entry-distance limit AND close ≤ EMA × reciprocal proximity factor
Calculation: Entry stop and target: FVG long stop = min(signal low, gap bottom) − ATR × stop multiple; volume long stop = signal low − ATR × stop multiple; retest long stop = min(signal low, retested level) − ATR × stop multiple. Short stops mirror these above the signal high, gap top, or retested level. Target is entry ± stop distance × strategy reward/risk multiple.
Long: FVG setup OR volume setup OR retest setup OR (flat position AND long pending AND long pending validity)
Short: FVG setup OR volume setup OR retest setup OR (flat position AND short pending AND short pending validity)
Exit: long, low ≤ long stop OR high ≥ long target
Exit: short, high ≥ short stop OR low ≤ short target