Calculation: CBC state = bullish after close > high[1] while bearish; bearish after close < low[1] while bullish; otherwise unchanged, initially bearish
Long: hour(datetime) >= entry-start hour AND hour(datetime) < entry-end hour AND CBC flips bullish AND EMA(close, slow lookback) >= VWAP(close) AND (strong-flips-only is disabled OR low < low[1])
Short: hour(datetime) >= entry-start hour AND hour(datetime) < entry-end hour AND CBC flips bearish AND EMA(close, slow lookback) < VWAP(close) AND (strong-flips-only is disabled OR high > high[1])
Exit: long, close <= low[1] OR high >= entry-signal bar close + ATR(ATR lookback) on entry-signal bar * target multiple
Exit: short, close >= high[1] OR low <= entry-signal bar close - ATR(ATR lookback) on entry-signal bar * target multiple