Calculation: Last high = last PivotHigh(high, pivot length, pivot length)
Calculation: Last low = last PivotLow(low, pivot length, pivot length)
Calculation: Last high bar = bar index of the last PivotHigh(high, pivot length, pivot length)
Calculation: Last low bar = bar index of the last PivotLow(low, pivot length, pivot length)
Calculation: Bull swing = Last high bar > Last low bar
Calculation: Bear swing = Last low bar > Last high bar
Calculation: Terminal = if Bull swing then Last high else Last low
Calculation: Origin = if Bull swing then Last low else Last high
Calculation: Leg height = abs(Terminal - Origin)
Calculation: Active swing = (Bull swing OR Bear swing) AND Leg height > minimum leg ATR multiple * ATR(ATR length) AND bar index - max(Last high bar, Last low bar) <= max swing age
Calculation: Near depth = shallow pocket depth - pocket offset
Calculation: Far depth = deep pocket depth + pocket offset, where Near depth < Far depth
Calculation: Pocket near = Terminal + Near depth * (Origin - Terminal)
Calculation: Pocket far = Terminal + Far depth * (Origin - Terminal)
Calculation: Pocket mid = (Pocket near + Pocket far) / 2
Calculation: Pocket touch = Active swing AND low <= max(Pocket near, Pocket far) AND high >= min(Pocket near, Pocket far)
Calculation: Defense lost = Active swing AND ((Bull swing AND close < Origin - defense buffer ATR multiple * ATR(ATR length)) OR (Bear swing AND close > Origin + defense buffer ATR multiple * ATR(ATR length)))
Calculation: Peak score(x, a, b, c) = if x <= b then clamp((x - a) / (b - a) * 100, 0, 100) else clamp((c - x) / (c - b) * 100, 0, 100), where a < b < c
Calculation: Close location = clamp((close - low) / (high - low), 0, 1)
Calculation: Clarity = leg height share * Peak score(Leg height / ATR(ATR length), low leg ATR, ideal leg ATR, high leg ATR) + (1 - leg height share) * Peak score(abs(Last high bar - Last low bar), max(minimum leg bars, pivot length), max(minimum ideal leg bars, ideal leg bars factor * pivot length), max swing age)
Calculation: Depth score = Peak score(clamp((if Bull swing then Terminal - low else high - Terminal) / Leg height, 0, depth cap), depth low factor * Near depth, ideal depth, depth high factor * Far depth)
Calculation: Rejection = clamp((if Bull swing then max(min(open, close) - low, 0) else max(high - max(open, close), 0)) / (high - low) * wick scale + (if Bull swing then Close location else 1 - Close location) * location scale, 0, 100)
Calculation: Close response = clamp((if Bull swing then close - Pocket mid else Pocket mid - close) / abs(Pocket near - Pocket far) * close response scale + (if Bull swing then Close location else 1 - Close location) * (100 - close response scale), 0, 100)
Calculation: Volume score = if use volume support then clamp((volume / SMA(volume, volume baseline length) - volume low) / (volume high - volume low) * 100, 0, 100) else volume neutral score
Calculation: Quality score = clamp(Clarity * clarity weight + Depth score * depth weight + Rejection * rejection weight + Close response * close response weight + Volume score * volume weight - score offset, 0, 100)
Calculation: Target guide = Terminal + target extension * (Terminal - Origin)
Calculation: Valid retest = Active swing AND barssince(Pocket touch) <= response window AND NOT Defense lost AND ((Bull swing AND close >= Pocket mid) OR (Bear swing AND close <= Pocket mid)) AND (if Bull swing then Target guide - close else close - Target guide) >= minimum target room ATR multiple * ATR(ATR length) AND Quality score >= valid threshold
Long: Valid retest AND NOT Valid retest[1] AND Bull swing
Short: Valid retest AND NOT Valid retest[1] AND Bear swing
Exit: long, Defense lost AND NOT Defense lost[1] AND Bull swing
Exit: short, Defense lost AND NOT Defense lost[1] AND Bear swing