Calculation: Donchian midline(lookback) = (highest high over lookback bars + lowest low over lookback bars) / 2
Calculation: Center = EMA((shortest midline weight * Donchian midline(shortest lookback) + middle midline weight * Donchian midline(middle lookback) + span A weight * Ichimoku Span A(shortest lookback, middle lookback) + longest midline weight * Donchian midline(longest lookback) + close weight * close) / (shortest midline weight + middle midline weight + span A weight + longest midline weight + close weight), center smoothing lookback)
Calculation: Body average = EMA(abs(close - open), body lookback)
Calculation: Channel width = MAX(EMA(ATR(atr lookback) * atr multiplier + Body average * body multiplier, width smoothing lookback), tick size * minimum width ticks)
Calculation: Compression = abs(close - open) <= Body average * compression body factor AND high - low <= EMA(high - low, regime lookback) * compression range factor AND ATR(atr lookback) <= EMA(ATR(atr lookback), regime lookback) * compression ATR factor
Calculation: Bull candidate = close > Center + Channel width AND (Center > Center[slope lookback] OR NOT slope agreement required)
Calculation: Bear candidate = close < Center - Channel width AND (Center < Center[slope lookback] OR NOT slope agreement required)
Calculation: Neutral candidate = compression neutralization enabled AND Compression AND abs(close - Center) < inner ratio * Channel width
Calculation: Trend state = Bull if Bull candidate, Bear if Bear candidate, Neutral if Neutral candidate, else Trend state[1]
Long: Bull candidate AND Trend state[1] != Bull
Short: Bear candidate AND Trend state[1] != Bear
Exit: long, Neutral candidate
Exit: short, Neutral candidate