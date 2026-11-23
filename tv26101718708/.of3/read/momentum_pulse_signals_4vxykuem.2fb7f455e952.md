Calculation: RSI score = (RSI(close, RSI lookback) - 50) / 50
Calculation: MACD score = MACD histogram(close, shorter EMA lookback, longer EMA lookback, signal EMA lookback) / (normalization scale * STDEV of that MACD histogram over normalization lookback), clamped to [-1, 1], or 0 when that STDEV is not positive
Calculation: Score = RSI weight * RSI score + (1 - RSI weight) * MACD score
Calculation: Bias = 1 if Score > trigger level; -1 if Score < -trigger level; otherwise Bias[1]
Calculation: Long stop distance = entry price - low of entry bar + stop multiplier * ATR(stop ATR lookback) at entry bar
Calculation: Short stop distance = high of entry bar - entry price + stop multiplier * ATR(stop ATR lookback) at entry bar
Long: Bias = 1 AND Bias[1] != 1 AND (slope agreement not required OR Score > Score[slope lookback]) AND (candle confirmation not required OR close > open) AND position side != long
Short: Bias = -1 AND Bias[1] != -1 AND (slope agreement not required OR Score < Score[slope lookback]) AND (candle confirmation not required OR close < open) AND position side != short
Exit: Long, high >= entry price + reward ratio * Long stop distance
Exit: Long, low <= entry price - Long stop distance AND high < entry price + reward ratio * Long stop distance
Exit: Short, low <= entry price - reward ratio * Short stop distance
Exit: Short, high >= entry price + Short stop distance AND low > entry price - reward ratio * Short stop distance
Long: Score > 0
Short: Score <= 0
Calculation: Band = band multiplier * SMA(high - low, ADR lookback)[1], computed on T1 bars and taken on chart bars from the last completed T1 bar
Calculation: Zone half-height = zone height multiplier * ATR(zone ATR lookback) / 2
Calculation: Zone level = mean of the pivot values joined to the zone, where a pivot high or low (pivot period bars back, confirmed on the current bar, source high/low or max/min of open and close per the pivot source parameter) joins the nearest zone whose level is within cluster width multiplier * ATR(zone ATR lookback), otherwise starts a new zone; a zone is removed when more than zone lookback bars have passed since the later of its last pivot bar and its last bar with Zone touch true
Calculation: Zone touch = high >= Zone level - Zone half-height AND low <= Zone level + Zone half-height
Calculation: Zone retests = number of bars where Zone touch is true and Zone touch[1] is false
Calculation: Zone bounces = number of bars where Zone touch[1] is true, Zone touch is false, and close[2] and close are both below Zone level - Zone half-height or both above Zone level + Zone half-height
Calculation: Zone breaks = number of bars where Zone touch[1] is true, Zone touch is false, and close[2] and close are on opposite sides, one below Zone level - Zone half-height and the other above Zone level + Zone half-height
Calculation: Zone wick average = mean of max(0, wick) over the bars counted by Zone retests, where wick = high - max(open, close) if Zone level >= close, else min(open, close) - low
Calculation: Zone pivot count = number of pivot values joined to the zone
Calculation: Zone last pivot bar = pivot bar of the most recent pivot joined to the zone
Calculation: Age factor = 1 if decay when idle is off, else max(1 - (1 - decay floor) * min(bars since Zone last pivot bar / decay bars, 1), decay floor)
Calculation: Zone quality = bounce weight * bounce share + wick weight * wick term, where bounce share = Zone bounces / (Zone bounces + Zone breaks) or neutral bounce share when that sum is 0, and wick term = min(Zone wick average / ATR(zone ATR lookback), 1) or 0 when Zone retests is 0
Calculation: Zone score = clamp(score maximum * Age factor * (retest-quantity weight * min(Zone retests / retests for full score, 1) + retest-quality weight * Zone quality + pivot-count weight * min(Zone pivot count / pivots for full score, 1)) / (retest-quantity weight + retest-quality weight + pivot-count weight), 0, score maximum)
Calculation: Selected zones = up to selection count zones, chosen one at a time as the eligible zone with the highest Zone score, where a zone is eligible if Zone retests >= min retests AND (strong-only not required OR Zone score >= strong threshold)
Calculation: Upper zone count = number of Selected zones with Zone level > close AND Zone level <= close + Band
Calculation: Lower zone count = number of Selected zones with Zone level < close AND Zone level >= close - Band
Long: Upper zone count > 0 AND (dual trace enabled OR Score >= 0)
Short: Lower zone count > 0 AND (dual trace enabled OR Score < 0)