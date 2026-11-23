Calculation: cycle index = piecewise linear interpolation through timestamp and cycle-index anchor parameters, extrapolated beyond the latest anchor using the interval between the two latest anchors
Calculation: cycle phase = fractional part of cycle index
Calculation: model bands = for safe cycle index s, decay = decay base^(s + decay offset); delay = if s < delay cutoff then delay offset + delay base^(s − delay exponent offset) × (delay amplitude + cos(delay frequency × (s + delay phase offset))) else delay offset; wave = sin(cycle frequency × (s − delay)); power = 10^(power intercept + power slope × log10(s)); rainbow floor = power × 10^(−decay); rainbow upper bands = power × 10^(decay × each band multiplier); wave floor, middle, upper, and top = power × 10^(decay × max(−1, wave + each band offset))
Calculation: rainbow floor distance = (close / rainbow floor − 1) × percentage scale; wave floor distance = (close / wave floor − 1) × percentage scale
Calculation: floors overlap = abs(wave floor / rainbow floor − 1) < overlap tolerance
Calculation: rainbow floor score = if rainbow floor distance ≤ cutoff 1 then score 1, else if ≤ cutoff 2 then score 2, else if ≤ cutoff 3 then score 3, else if ≤ cutoff 4 then score 4, else if ≤ cutoff 5 then score 5, else if ≤ cutoff 6 then score 6, else score 7
Calculation: wave floor score = if wave floor distance ≤ cutoff 1 then score 1, else if ≤ cutoff 2 then score 2, else if ≤ cutoff 3 then score 3, else if ≤ cutoff 4 then score 4, else if ≤ cutoff 5 then score 5, else score 6
Calculation: combined floor score = if floors overlap then rainbow floor score else floor mix weight × rainbow floor score + (1 − floor mix weight) × wave floor score
Calculation: bottom phase score = score 1 if cycle phase is within window 1, else score 2 if within window 2, else score 3 if within window 3, else score 4 if within window 4, else score 5
Calculation: top phase score = score 1 if cycle phase is within window 1, else score 2 if within window 2, else score 3 if within window 3, else score 4
Calculation: daily RSI accumulation score = RSI(close, RSI lookback) on chart bars, scored by successive upper cutoffs and a final default score
Calculation: T1 RSI accumulation score = RSI(close, RSI lookback, T1, forming bar sampled on chart bars with lookahead off), scored by successive upper cutoffs and a final default score
Calculation: daily RSI distribution score = RSI(close, RSI lookback) on chart bars, scored by successive lower cutoffs and a final default score
Calculation: T1 RSI distribution score = RSI(close, RSI lookback, T1, forming bar sampled on chart bars with lookahead off), scored by successive lower cutoffs and a final default score
Calculation: momentum recovery score = score 1 if MACD(close, fast lookback, slow lookback, signal lookback) line > signal line and daily RSI < cutoff 1, else score 2 if MACD line > signal line, else score 3 if MACD histogram > its prior chart-bar value, else score 4
Calculation: volume confirmation score = volume / SMA(volume, volume lookback) scored by successive lower cutoffs and a final default score; use the fallback ratio when the average is unavailable or nonpositive
Calculation: accumulation score = clamp(floor weight × combined floor score + bottom-phase weight × bottom phase score + daily-RSI weight × daily RSI accumulation score + T1-RSI weight × T1 RSI accumulation score + momentum weight × momentum recovery score + volume weight × volume confirmation score, minimum score, maximum score)
Calculation: upper-band score = score 1 if close ≥ rainbow top, else score 2 if close ≥ rainbow upper band 3, else score 3 if close ≥ rainbow upper band 2, else score 4 if close ≥ rainbow upper band 1, else score 5
Calculation: wave-top score = score 1 if close ≥ wave top, else score 2 if close ≥ wave upper, else score 3 if close ≥ wave middle, else score 4
Calculation: volatility risk score = ATR(high, low, close, ATR lookback) / close × percentage scale, scored by successive lower cutoffs and a final default score; use the fallback value when close is nonpositive
Calculation: distribution score = clamp(rainbow upper-band weight × upper-band score + wave-top weight × wave-top score + top-phase weight × top phase score + daily-RSI weight × daily RSI distribution score + T1-RSI weight × T1 RSI distribution score + volatility weight × volatility risk score, minimum score, maximum score)
Calculation: trend health score = score 1 if close exceeds both chart-bar SMA(close, SMA lookback) and SMA(close, SMA lookback, T1, forming bar sampled on chart bars with lookahead off), else score 2 if it exceeds the T1 average, else score 3 if it exceeds the chart-bar average, else score 4
Calculation: floor confluence score = if floors overlap then maximum score else clamp(maximum score − abs(wave floor / rainbow floor − 1) × confluence scale, minimum score, maximum score)
Calculation: floor respect score = score 1 if close < rainbow floor × deep-break factor, else score 2 if close < rainbow floor, else score 3 if rainbow floor distance ≤ cutoff 1, else score 4 if ≤ cutoff 2, else score 5 if ≤ cutoff 3, else score 6
Calculation: model confidence = clamp(floor-respect weight × floor respect score + confluence weight × floor confluence score + bottom-phase weight × bottom phase score + trend weight × trend health score, minimum score, maximum score)
Calculation: cycle health = clamp(model-confidence weight × model confidence + trend weight × trend health score + momentum weight × momentum recovery score + confluence weight × floor confluence score + volatility weight × (maximum score − volatility risk score) + volume weight × volume confirmation score, minimum score, maximum score)
Calculation: BRC score = clamp(accumulation weight × accumulation score + inverse-distribution weight × (maximum score − distribution score) + confidence weight × model confidence + health weight × cycle health, minimum score, maximum score)
Calculation: net bias = accumulation score − distribution score
Calculation: cycle mode = DISTRIBUTE if distribution score ≥ distribution cutoff 1, else REDUCE RISK if distribution score ≥ distribution cutoff 2, else ACCUMULATION+ if accumulation score ≥ accumulation cutoff 1, else ACCUMULATION if accumulation score ≥ accumulation cutoff 2, else NEUTRAL
Calculation: model status = BROKEN if close < rainbow floor × deep-break factor, else WARNING if close < rainbow floor, else VALID
Calculation: extreme floor = min(rainbow floor, wave floor) × extreme-floor factor
Long: accumulation score crosses above alert threshold 1 OR accumulation score crosses above alert threshold 2
Short: distribution score crosses above alert threshold 1 OR distribution score crosses above alert threshold 2
Short: close crosses below rainbow floor
Long: close crosses above rainbow floor OR close crosses below extreme floor
Long: cycle mode becomes ACCUMULATION+
Short: cycle mode becomes DISTRIBUTE
Short: model status becomes WARNING OR model status becomes BROKEN
Long: BRC score ≥ dashboard green cutoff
Short: BRC score < dashboard red cutoff
Long: cycle mode is neither DISTRIBUTE nor REDUCE RISK
Long: net bias ≥ zero threshold
Short: net bias < zero threshold
Long: model status = VALID
Short: model status = BROKEN
Long: rainbow floor distance ≤ green distance cutoff
Short: rainbow floor distance > red distance cutoff
Short: distribution score ≥ label cutoff
Long: distribution score < label cutoff AND accumulation score ≥ label cutoff
Long: cycle phase is within the accumulation phase interval
Short: cycle phase is within the distribution phase interval