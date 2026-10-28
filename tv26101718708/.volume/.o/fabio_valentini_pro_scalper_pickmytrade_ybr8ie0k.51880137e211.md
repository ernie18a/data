Calculation: Absorption = volume > 20-bar average volume × volume multiplier AND abs(close − open) / ATR(14) < maximum movement threshold
Calculation: Buy volume = volume if close > open; half of volume if close = open; otherwise volume × (high − close) / (high − low + 0.0001); sell volume = volume − buy volume; smoothed delta = lookback SMA of buy volume − sell volume
Calculation: Buyers control = smoothed delta > 0 AND smoothed delta > prior-bar smoothed delta; sellers control = smoothed delta < 0 AND smoothed delta < prior-bar smoothed delta
Calculation: Value area levels = assign each of the lookback bars' volume to a price bin based on its close between the rolling lookback low and high; POC is the center of the highest-volume bin; expand from POC into adjacent bins, choosing the higher-volume side first, until 70% of assigned volume is included; VAH and VAL are the resulting upper and lower boundaries
Calculation: Contraction = 10-bar high − low < 0.6 × 50-bar average of the 10-bar high − low
Calculation: Expansion = 10-bar high − low > 1.2 × 50-bar average of the 10-bar high − low AND volume > 1.5 × 20-bar average volume
Calculation: Opening range high/low = highest high and lowest low during the first configured number of minutes of the current session; use only after that range is defined
Calculation: VWAP lower/upper bands = current-session VWAP of hlc3 −/+ ATR(14) × band multiplier
Long: Absorption AND close > open
Long: Absorption on the current bar AND close > open AND absorption on at least one of the bars 3–5 bars earlier AND prior-bar contraction AND current-bar expansion AND close > open AND smoothed delta > 0
Long: Opening range is defined AND close > opening range high AND prior close ≤ opening range high
Long: Low is within 0.1% of VAL AND Absorption AND close > open AND buyers control
Long: (Triple-A long setup OR opening range breakout long OR VAL bounce) AND (VWAP filter disabled OR close > VWAP lower band) AND (session filter disabled OR current bar is within configured session) AND daily losses < configured limit AND position is flat
Short: Absorption AND close < open
Short: Absorption on the current bar AND close < open AND absorption on at least one of the bars 3–5 bars earlier AND prior-bar contraction AND current-bar expansion AND close < open AND smoothed delta < 0
Short: Opening range is defined AND close < opening range low AND prior close ≥ opening range low
Short: High is within 0.1% of VAH AND Absorption AND close < open AND sellers control
Short: (Triple-A short setup OR opening range breakout short OR VAH bounce) AND (VWAP filter disabled OR close < VWAP upper band) AND (session filter disabled OR current bar is within configured session) AND daily losses < configured limit AND position is flat
Exit: long, price ≤ entry-signal-bar low − ATR(14) OR price ≥ entry-signal-bar close + (entry-signal-bar close − stop) × risk/reward ratio OR trailing stop is hit after price advances by the configured trail offset, with trail distance set by ATR(14) × trailing multiplier
Exit: short, price ≥ entry-signal-bar high + ATR(14) OR price ≤ entry-signal-bar close − (stop − entry-signal-bar close) × risk/reward ratio OR trailing stop is hit after price advances by the configured trail offset, with trail distance set by ATR(14) × trailing multiplier