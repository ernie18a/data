Calculation: bullish VWAP count = count of available VWAP((open + high + low + close) / 4, futures-session start), VWAP((open + high + low + close) / 4, NY-session start), VWAP((open + high + low + close) / 4, previous NY-session start through current bar), VWAP((open + high + low + close) / 4, current futures-session high), and VWAP((open + high + low + close) / 4, current futures-session low) values below close
Long: VWAP((open + high + low + close) / 4, futures-session start) is available AND close > VWAP((open + high + low + close) / 4, futures-session start)
Short: VWAP((open + high + low + close) / 4, futures-session start) is unavailable OR close <= VWAP((open + high + low + close) / 4, futures-session start)
Long: within NY session AND VWAP((open + high + low + close) / 4, NY-session start) is available AND close > VWAP((open + high + low + close) / 4, NY-session start)
Short: outside NY session OR VWAP((open + high + low + close) / 4, NY-session start) is unavailable OR close <= VWAP((open + high + low + close) / 4, NY-session start)
Long: within NY session AND VWAP((open + high + low + close) / 4, previous NY-session start through current bar) is available AND close > VWAP((open + high + low + close) / 4, previous NY-session start through current bar)
Short: outside NY session OR VWAP((open + high + low + close) / 4, previous NY-session start through current bar) is unavailable OR close <= VWAP((open + high + low + close) / 4, previous NY-session start through current bar)
Long: VWAP((open + high + low + close) / 4, current futures-session high) is available AND close > VWAP((open + high + low + close) / 4, current futures-session high)
Short: VWAP((open + high + low + close) / 4, current futures-session high) is unavailable OR close <= VWAP((open + high + low + close) / 4, current futures-session high)
Long: VWAP((open + high + low + close) / 4, current futures-session low) is available AND close > VWAP((open + high + low + close) / 4, current futures-session low)
Short: VWAP((open + high + low + close) / 4, current futures-session low) is unavailable OR close <= VWAP((open + high + low + close) / 4, current futures-session low)
Long: close > current NY opening-range high
Short: close < current NY opening-range low
Long: bullish VWAP count >= long-trend threshold
Short: bullish VWAP count <= short-trend threshold