Calculation: scaled swing lookback = clamp(round(swing lookback * (reference minutes / chart minutes) ^ swing lookback scaling exponent), minimum swing lookback, maximum swing lookback)
Calculation: scaled trend MA length = clamp(round(trend MA length * (reference minutes / chart minutes)), minimum trend MA length, maximum trend MA length)
Calculation: in session = session filter disabled OR bar time within session window in session time zone
Calculation: tracked swing lows = up to tracked swing level count most recent values of pivot low(low, scaled swing lookback, scaled swing lookback), each kept only if it differs from the last kept low by more than swing dedupe ATR multiple * ATR(ATR length)
Calculation: tracked swing highs = up to tracked swing level count most recent values of pivot high(high, scaled swing lookback, scaled swing lookback), each kept only if it differs from the last kept high by more than swing dedupe ATR multiple * ATR(ATR length)
Calculation: bull sweep = for some tracked swing low L, (low < L AND (close-back disabled OR close > L)) OR (close-back enabled AND low[1] < L AND close[1] < L AND close > L)
Calculation: bear sweep = for some tracked swing high H, (high > H AND (close-back disabled OR close < H)) OR (close-back enabled AND high[1] > H AND close[1] > H AND close < H)
Calculation: sized gap qualifies(x) = x > 0 AND x >= minimum FVG ATR multiple * ATR(ATR length) AND (maximum FVG disabled OR x <= maximum FVG ATR multiple * ATR(ATR length))
Calculation: bull FVG = sized gap qualifies(low - high[2]) OR sized gap qualifies(low - high[1])
Calculation: bear FVG = sized gap qualifies(low[2] - high) OR sized gap qualifies(low[1] - high)
Calculation: bull arm event = bull FVG AND in-session bars from the most recent bull sweep (exclusive) through this bar <= sweep window; its setup top = low, setup bottom = high[2] if sized gap qualifies(low - high[2]) else high[1], setup stop = lowest swept low of that most recent bull sweep (low[1] for a delayed close-back sweep) - stop buffer ATR multiple * ATR(ATR length)
Calculation: bear arm event = bear FVG AND in-session bars from the most recent bear sweep (exclusive) through this bar <= sweep window; its setup top = low[2] if sized gap qualifies(low[2] - high) else low[1], setup bottom = high, setup stop = highest swept high of that most recent bear sweep (high[1] for a delayed close-back sweep) + stop buffer ATR multiple * ATR(ATR length)
Calculation: bull setup armed = the latest arm event is a bull arm event AND bars since it <= entry window AND low >= its setup stop on every bar from it through this bar AND no long entry since it
Calculation: bear setup armed = the latest arm event is a bear arm event AND bars since it <= entry window AND high <= its setup stop on every bar from it through this bar AND no short entry since it
Calculation: long risk = (setup top - (setup top - setup bottom) * entry depth fraction if limit entry mode, else close) - setup stop
Calculation: short risk = setup stop - (setup bottom + (setup top - setup bottom) * entry depth fraction if limit entry mode, else close)
Calculation: dashboard sweep on T1 = bull or bear, taken from the latest T1 bar (last completed bar) within dashboard sweep window bars of this bar that is a bull sweep (low < latest pivot low(low, dashboard pivot lookback, dashboard pivot lookback, T1, last completed bar) as of that bar AND close > that pivot low) or a bear sweep (high > latest pivot high(high, dashboard pivot lookback, dashboard pivot lookback, T1, last completed bar) as of that bar AND close < that pivot high), with bear preferred on the same bar
Long: bull setup armed AND low <= setup top + near-miss fraction * (setup top - setup bottom) AND high >= setup bottom - near-miss fraction * (setup top - setup bottom) AND close > open AND (close - open) / (high - low) > momentum body fraction AND close > setup bottom AND in session AND long risk > 0 AND (risk cap disabled OR long risk <= max risk ATR multiple * ATR(ATR length)) AND (trend filter disabled OR close > SMA(close, scaled trend MA length))
Short: bear setup armed AND low <= setup top + near-miss fraction * (setup top - setup bottom) AND high >= setup bottom - near-miss fraction * (setup top - setup bottom) AND close < open AND (open - close) / (high - low) > momentum body fraction AND close < setup top AND in session AND short risk > 0 AND (risk cap disabled OR short risk <= max risk ATR multiple * ATR(ATR length)) AND (trend filter disabled OR close < SMA(close, scaled trend MA length))
Exit: long, low <= (entry price if break-even enabled AND high >= entry price + long risk * break-even R:R on some bar from entry through this bar, else setup stop) OR high >= (nearest tracked swing high above entry price as of the entry bar if opposite-liquidity target mode AND that high > entry price + long risk * target R:R, else entry price + long risk * target R:R) OR (time stop enabled AND bars since entry >= max bars) OR bull arm event OR bear arm event
Exit: short, high >= (entry price if break-even enabled AND low <= entry price - short risk * break-even R:R on some bar from entry through this bar, else setup stop) OR low <= (nearest tracked swing low below entry price as of the entry bar if opposite-liquidity target mode AND that low < entry price - short risk * target R:R, else entry price - short risk * target R:R) OR (time stop enabled AND bars since entry >= max bars) OR bull arm event OR bear arm event
Long: bull sweep
Short: bear sweep
Long: bull FVG
Short: bear FVG
Long: bull setup armed
Short: bear setup armed
Long: close > SMA(close, dashboard bias MA length, T1, last completed bar)
Short: close <= SMA(close, dashboard bias MA length, T1, last completed bar)
Long: dashboard sweep on T1 = bull
Short: dashboard sweep on T1 = bear
Long: on T2 bars (last completed bar), the latest bar with low > high[2] has no later close below that bar's high[2]
Short: on T2 bars (last completed bar), the latest bar with high < low[2] has no later close above that bar's low[2]