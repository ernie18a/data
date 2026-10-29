Calculation: Prior-period S/R levels = high and low of the last completed bars from four higher timeframes with progressively longer period lengths
Calculation: Prior-session S/R levels = high and low of each configured session’s most recently completed session
Calculation: Touch(level) = low <= level + close × tolerance% AND high >= level − close × tolerance%
Calculation: Bullish rejection(level) = Touch(level) AND close > level AND close > open
Calculation: Bearish rejection(level) = Touch(level) AND close < level AND close < open
Calculation: Near(level) = absolute(close − level) / close < proximity%
Calculation: Volume spike = volume > moving-average volume × multiplier
Calculation: Bull trend = close > shorter-lookback EMA > longer-lookback EMA
Calculation: Bear trend = close < shorter-lookback EMA < longer-lookback EMA
Calculation: Long score = parameter-weighted sum of bullish rejections at prior-period lows (weights increase with period length) and prior-session lows, plus shared bonuses for Near any of the three longer-period prior S/R pairs, Near any prior-session high or low, and a volume spike
Calculation: Short score = parameter-weighted sum of bearish rejections at prior-period highs (weights increase with period length) and prior-session highs, plus shared bonuses for Near any of the three longer-period prior S/R pairs, Near any prior-session high or low, and a volume spike
Long: (Long score >= score threshold AND (trend filter disabled OR Bull trend) AND (volume filter disabled OR Volume spike) AND (no prior long signal within cooldown bars)) OR (close > prior-period high of the shortest period AND previous close <= that level AND Volume spike)
Short: (Short score >= score threshold AND (trend filter disabled OR Bear trend) AND (volume filter disabled OR Volume spike) AND (no prior short signal within cooldown bars)) OR (close < prior-period low of the shortest period AND previous close >= that level AND Volume spike)